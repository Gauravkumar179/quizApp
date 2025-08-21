import 'package:cloud_firestore/cloud_firestore.dart';

class LiveQuiz {
  final String quizId;
  final String title;
  final String description;
  final String? bannerUrl;
  final DateTime starttime;
  final DateTime endtime;
  final bool isActive;
  final int totalQuestions;
  final String difficulty;
  final List<QuizQuestion> questions;

  LiveQuiz({
    required this.quizId,
    required this.title,
    required this.description,
    this.bannerUrl,
    required this.starttime,
    required this.endtime,
    required this.isActive,
    required this.totalQuestions,
    required this.difficulty,
    required this.questions,
  });

  factory LiveQuiz.fromFirestore(Map<String, dynamic> data, String quizId) {
    return LiveQuiz(
      quizId: data['quizId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      bannerUrl: data['bannerUrl'],
      starttime: (data['starttime'] as Timestamp).toDate(),
      endtime: (data['endtime'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      totalQuestions: data['totalQuestions'] ?? 0,
      difficulty: data['difficulty'] ?? 'Medium',
      questions:
          (data['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q))
              .toList() ??
          [],
    );
  }

  bool get isLive {
    final now = DateTime.now();
    return isActive && now.isAfter(starttime) && now.isBefore(endtime);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return isActive && now.isBefore(starttime);
  }

  bool get isEnded {
    final now = DateTime.now();
    return now.isAfter(endtime);
  }

  Duration get timeUntilStart {
    final now = DateTime.now();
    return starttime.difference(now);
  }

  Duration get timeUntilEnd {
    final now = DateTime.now();
    return endtime.difference(now);
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> data) {
    return QuizQuestion(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      answer: data['Answer'] ?? '',
    );
  }
}

class LeaderboardEntry {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String quizId;
  final String title;
  final int points;
  final int timeTakenSec;
  final int timeTakenMs;
  final DateTime completedAt;

  LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.quizId,
    required this.title,
    required this.points,
    required this.timeTakenSec,
    required this.timeTakenMs,
    required this.completedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'quizId': quizId,
      'title': title,
      'points': points,
      'timeTakenSec': timeTakenSec,
      'timeTakenMs': timeTakenMs,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
