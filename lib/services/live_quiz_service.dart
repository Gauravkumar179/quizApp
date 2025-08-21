import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/live_quiz_model.dart';

class LiveQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<LiveQuiz>> getLiveQuizzes() {
    return _firestore
        .collection('live_quizzes')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LiveQuiz.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  Future<bool> hasUserTakenQuiz(String quizId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final query = await _firestore
        .collection('leaderboard')
        .where('uid', isEqualTo: user.uid)
        .where('quizId', isEqualTo: quizId)
        .get();

    return query.docs.isNotEmpty;
  }

  /// 🔹 Stream-based version (auto updates if user submits result later)
  Stream<bool> hasUserTakenQuizStream(String quizId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('leaderboard')
        .where('uid', isEqualTo: user.uid)
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> submitQuizResult({
    required String quizId,
    required String quizTitle,
    required int points,
    required int timeTakenSec,
    required int timeTakenMs,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if user already took this quiz
    final hasAlreadyTaken = await hasUserTakenQuiz(quizId);
    if (hasAlreadyTaken) {
      throw Exception('You have already taken this quiz');
    }

    final leaderboardEntry = LeaderboardEntry(
      uid: user.uid,
      name: user.displayName ?? 'Anonymous',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      quizId: quizId,
      title: quizTitle,
      points: points,
      timeTakenSec: timeTakenSec,
      timeTakenMs: timeTakenMs,
      completedAt: DateTime.now(),
    );

    await _firestore
        .collection('leaderboard')
        .add(leaderboardEntry.toFirestore());
  }

  /// ✅ Ordered leaderboard (highest points first, then fastest time wins ties)
  Stream<List<LeaderboardEntry>> getLeaderboard(String quizId) {
    return _firestore
        .collection('leaderboard')
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) {
          final entries = snapshot.docs.map((doc) {
            final data = doc.data();
            return LeaderboardEntry(
              uid: data['uid'],
              name: data['name'],
              email: data['email'],
              photoUrl: data['photoUrl'],
              quizId: data['quizId'],
              title: data['title'],
              points: data['points'],
              timeTakenSec: data['timeTakenSec'] ?? 0,
              timeTakenMs: data['timeTakenMs'] ?? 0,
              completedAt: (data['completedAt'] as Timestamp).toDate(),
            );
          }).toList();

          // ✅ Sort here instead of Firestore
          entries.sort((a, b) {
            if (b.points != a.points) {
              return b.points.compareTo(a.points); // higher score first
            }
            return a.timeTakenMs.compareTo(b.timeTakenMs); // faster wins ties
          });

          return entries;
        });
  }
}
