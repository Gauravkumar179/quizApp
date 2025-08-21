import 'package:flutter/material.dart';
import '../models/live_quiz_model.dart';
import '../services/live_quiz_service.dart';
import 'live_quiz_play_page.dart';

class LiveQuizSlider extends StatelessWidget {
  const LiveQuizSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LiveQuiz>>(
      stream: LiveQuizService().getLiveQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No live quizzes available right now",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final quizzes = snapshot.data!;

        return SizedBox(
          height: 200,
          width: double.infinity,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _buildQuizCard(context, quiz);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuizCard(BuildContext context, LiveQuiz quiz) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: quiz.isLive
              ? [const Color(0xFF4CAF50), const Color(0xFF45a049)]
              : quiz.isUpcoming
              ? [const Color(0xFFFF9800), const Color(0xFFe68900)]
              : [Colors.grey, Colors.grey[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: quiz.bannerUrl != null
            ? DecorationImage(
                image: NetworkImage(quiz.bannerUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (quiz.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            _buildQuizInfo(quiz),
            const SizedBox(height: 12),
            _buildActionButton(context, quiz),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfo(LiveQuiz quiz) {
    if (quiz.isLive) {
      return _countdownText("Ends in", quiz.timeUntilEnd);
    } else if (quiz.isUpcoming) {
      return _countdownText("Starts in", quiz.timeUntilStart);
    } else {
      return const Text(
        "Quiz Ended",
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }
  }

  Widget _countdownText(String label, Duration duration) {
    return TweenAnimationBuilder<Duration>(
      duration: duration,
      tween: Tween(begin: duration, end: Duration.zero),
      onEnd: () {}, // you can refresh state if needed
      builder: (context, value, child) {
        final text = _formatDuration(value);
        return Text(
          "$label: $text",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, LiveQuiz quiz) {
    if (quiz.isEnded) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: null,
        child: const Text("Ended"),
      );
    }

    if (quiz.isUpcoming) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFFF9800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: null,
        child: const Text("Coming Soon"),
      );
    }

    // Quiz is live
    // Quiz is live
    return StreamBuilder<bool>(
      stream: LiveQuizService().hasUserTakenQuizStream(quiz.quizId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 80,
            height: 36,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final hasAlreadyTaken = snapshot.data!;

        if (hasAlreadyTaken) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: null,
            child: const Text("Completed"),
          );
        }

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveQuizPlayPage(quiz: quiz),
              ),
            );
          },
          child: const Text("Play Now"),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "0s";

    if (duration.inDays > 0) {
      return "${duration.inDays}d ${duration.inHours % 24}h";
    } else if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes % 60}m";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes}m ${duration.inSeconds % 60}s";
    } else {
      return "${duration.inSeconds}s";
    }
  }
}
