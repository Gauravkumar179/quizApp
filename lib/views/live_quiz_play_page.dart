import 'package:flutter/material.dart';
import 'dart:async';
import '../models/live_quiz_model.dart';
import '../services/live_quiz_service.dart';
import 'live_quiz_result_page.dart';

class LiveQuizPlayPage extends StatefulWidget {
  final LiveQuiz quiz;

  const LiveQuizPlayPage({super.key, required this.quiz});

  @override
  State<LiveQuizPlayPage> createState() => _LiveQuizPlayPageState();
}

class _LiveQuizPlayPageState extends State<LiveQuizPlayPage>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  bool isLoading = false;

  Timer? questionTimer;
  int timeLeft = 10; // 10 seconds per question

  late AnimationController _progressController;
  late AnimationController _scaleController;

  late Stopwatch stopwatch; // ⏱ total time tracker

  @override
  void initState() {
    super.initState();

    stopwatch = Stopwatch()..start(); // start overall timer

    _progressController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _startQuestionTimer();
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    _progressController.dispose();
    _scaleController.dispose();
    stopwatch.stop();
    super.dispose();
  }

  void _startQuestionTimer() {
    timeLeft = 10;
    _progressController.reset();
    _progressController.forward();

    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeLeft--;
        });

        if (timeLeft <= 0) {
          timer.cancel();
          if (!isAnswered) {
            _handleTimeUp();
          }
        }
      }
    });
  }

  void _handleTimeUp() {
    setState(() {
      isAnswered = true;
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    Timer(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _selectAnswer(String answer) {
    if (isAnswered) return;

    questionTimer?.cancel();

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    final currentQuestion = widget.quiz.questions[currentQuestionIndex];
    if (answer == currentQuestion.answer) {
      score += 10;
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }

    Timer(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
      });
      _startQuestionTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    setState(() {
      isLoading = true;
    });

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    try {
      await LiveQuizService().submitQuizResult(
        quizId: widget.quiz.quizId,
        quizTitle: widget.quiz.title,
        points: score,
        timeTakenMs: duration.inMilliseconds,
        timeTakenSec: duration.inSeconds,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LiveQuizResultPage(
              quiz: widget.quiz,
              score: score,
              totalQuestions: widget.quiz.questions.length,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Submitting your results...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = widget.quiz.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showExitDialog(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'LIVE QUIZ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.quiz.title,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Score: $score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // timer
              AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_scaleController.value * 0.1),
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return CircularProgressIndicator(
                                  value: 1.0 - _progressController.value,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    timeLeft <= 3
                                        ? Colors.red
                                        : const Color(0xFF4CAF50),
                                  ),
                                );
                              },
                            ),
                          ),
                          Center(
                            child: Text(
                              '$timeLeft',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: timeLeft <= 3
                                    ? Colors.red
                                    : const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // question + options
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentQuestion.options.length,
                          itemBuilder: (context, index) {
                            final option = currentQuestion.options[index];
                            final isSelected = selectedAnswer == option;
                            final isCorrect = option == currentQuestion.answer;

                            Color backgroundColor = Colors.grey[50]!;
                            Color borderColor = Colors.grey[300]!;
                            Color textColor = const Color(0xFF2D3748);

                            if (isAnswered) {
                              if (isCorrect) {
                                backgroundColor = Colors.green[50]!;
                                borderColor = Colors.green;
                                textColor = Colors.green[700]!;
                              } else if (isSelected && !isCorrect) {
                                backgroundColor = Colors.red[50]!;
                                borderColor = Colors.red;
                                textColor = Colors.red[700]!;
                              }
                            } else if (isSelected) {
                              backgroundColor = const Color(
                                0xFF4CAF50,
                              ).withOpacity(0.1);
                              borderColor = const Color(0xFF4CAF50);
                              textColor = const Color(0xFF4CAF50);
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _selectAnswer(option),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: borderColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: borderColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      if (isAnswered && isCorrect)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      else if (isAnswered &&
                                          isSelected &&
                                          !isCorrect)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Live Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost and you won\'t be able to rejoin this live quiz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
