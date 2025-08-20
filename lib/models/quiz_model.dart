import 'question_model.dart';

class Quiz {
  final String topic;
  final List<Question> questions;

  Quiz({required this.topic, required this.questions});

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}
