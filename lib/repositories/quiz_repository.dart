import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/question_model.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Save quiz attempt to user history
  Future<void> saveQuizHistory({
    required String subject,
    required String topic,
    required int score,
    required int total,
    required String difficulty,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final percentage = ((score / total) * 100).round();

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("quiz_history")
        .add({
          "subject": subject,
          "topic": topic,
          "score": score,
          "total": total,
          "percentage": percentage,
          "difficulty": difficulty,
          "createdAt": FieldValue.serverTimestamp(),
        });

    print("✅ Quiz history saved for $topic ($score/$total)");
  }

  /// Get quiz history for current user (real-time updates)
  Stream<List<Map<String, dynamic>>> getQuizHistory() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("quiz_history")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Generate cache key
  String _generateCacheKey(
    String topic,
    int numberOfQuestions,
    String difficulty,
  ) {
    return '${topic.toLowerCase().replaceAll(' ', '_')}_${numberOfQuestions}_${difficulty.toLowerCase()}';
  }

  /// Build AI prompt
  String _buildPrompt(String topic, int numberOfQuestions, String difficulty) {
    String difficultyInstruction = switch (difficulty.toLowerCase()) {
      'easy' =>
        'Make questions straightforward and basic level, suitable for beginners.',
      'medium' =>
        'Make questions moderately challenging with some application.',
      'hard' =>
        'Make questions challenging and complex with critical thinking.',
      _ => 'Make questions at an appropriate difficulty level.',
    };

    return '''
Generate exactly $numberOfQuestions multiple choice quiz questions about "$topic".

DIFFICULTY LEVEL: $difficulty
$difficultyInstruction

Return only valid JSON following the response schema.
''';
  }

  /// Validate generated questions
  bool _validateQuestions(List<Question> questions, int expectedCount) {
    if (questions.length != expectedCount) return false;
    for (final q in questions) {
      if (q.question.trim().isEmpty) return false;
      if (q.options.length != 4) return false;
      if (!q.options.contains(q.answer)) return false;
    }
    return true;
  }

  /// Generate quiz using Firebase AI
  Future<Quiz> generateQuiz(
    String topic, {
    int numberOfQuestions = 10,
    String difficulty = 'Medium',
    int retries = 3,
    bool useCache = true,
  }) async {
    if (topic.trim().isEmpty) throw ArgumentError('Topic cannot be empty');
    final cacheKey = _generateCacheKey(topic, numberOfQuestions, difficulty);
    print('🔄 Generating quiz for topic: $topic, cacheKey: $cacheKey');

    // Try cache first
    if (useCache) {
      try {
        final cached = await _firestore
            .collection('quizzes')
            .where('cacheKey', isEqualTo: cacheKey)
            .limit(1)
            .get();

        if (cached.docs.isNotEmpty) {
          final data = cached.docs.first.data();
          final questions = (data['questions'] as List)
              .map((q) => Question.fromMap(q))
              .toList();
          if (_validateQuestions(questions, numberOfQuestions)) {
            print('✅ Loaded quiz from cache');
            return Quiz(topic: topic, questions: questions);
          }
        }
      } catch (e) {
        print('⚠️ Cache load failed: $e');
      }
    }

    // Generate with AI
    for (int attempt = 1; attempt <= retries; attempt++) {
      print('⚡ Attempt $attempt to generate quiz for $topic');
      try {
        final ai = FirebaseAI.googleAI();
        final model = ai.generativeModel(
          model: 'gemini-1.5-flash',
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: Schema.array(
              items: Schema.object(
                properties: {
                  'question': Schema.string(),
                  'options': Schema.array(items: Schema.string()),
                  'answer': Schema.string(),
                },
              ),
            ),
          ),
        );

        final response = await model.generateContent([
          Content.text(_buildPrompt(topic, numberOfQuestions, difficulty)),
        ]);

        print('📥 Raw response: $response');
        final rawText = response.text ?? '[]';
        print('📥 Parsed text: $rawText');

        final parsed = jsonDecode(rawText) as List;
        final questions = parsed.map((q) => Question.fromMap(q)).toList();

        if (!_validateQuestions(questions, numberOfQuestions)) {
          throw Exception('❌ Validation failed');
        }

        final quiz = Quiz(topic: topic, questions: questions);

        // Cache quiz
        if (useCache) {
          await _firestore.collection('quizzes').add({
            ...quiz.toMap(),
            'cacheKey': cacheKey,
            'numberOfQuestions': numberOfQuestions,
            'difficulty': difficulty,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('💾 Quiz cached');
        }

        return quiz;
      } catch (e, s) {
        print('❌ AI generation error: $e');
        print(s);
        if (attempt == retries) {
          print('⚠️ Falling back to sample quiz');
          return _createFallbackQuiz(topic, numberOfQuestions);
        }
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    return _createFallbackQuiz(topic, numberOfQuestions);
  }

  /// Fallback quiz
  Quiz _createFallbackQuiz(String topic, int numberOfQuestions) {
    return Quiz(
      topic: topic,
      questions: List.generate(
        numberOfQuestions,
        (i) => Question(
          question: "Sample question ${i + 1} about $topic",
          options: ["Option A", "Option B", "Option C", "Option D"],
          answer: "Option A",
        ),
      ),
    );
  }
}
