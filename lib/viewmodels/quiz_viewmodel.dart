import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/question_model.dart';
import '../models/quiz_model.dart';
import '../repositories/quiz_repository.dart';

class QuizViewModel extends GetxController {
  final QuizRepository _repository = QuizRepository();

  // Existing variables
  var questions = <Question>[].obs;
  var currentQuestionIndex = 0.obs;
  var score = 0.obs;
  var isLoading = false.obs;

  // New dropdown selection variables
  var selectedClass = ''.obs;
  var selectedSubject = ''.obs;
  var selectedTopic = ''.obs;
  var selectedSubtopic = ''.obs;

  // Quiz settings
  var numberOfQuestions = 10.obs;
  var difficulty = 'Medium'.obs;

  // Quiz state management
  var quizStarted = false.obs;
  var quizCompleted = false.obs;
  var selectedAnswers = <String>[].obs;
  var correctAnswers = <bool>[].obs;

  // Auto-navigation settings
  var autoNavigateToHome = true.obs;
  var navigationDelay = 5.obs; // seconds - increased for better UX

  // Dropdown data
  List<String> get classes => [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
    'Undergraduate',
    'Graduate',
  ];

  List<String> get subjects {
    if (selectedClass.value.isEmpty) return [];

    if (selectedClass.value.contains('Class 6') ||
        selectedClass.value.contains('Class 7') ||
        selectedClass.value.contains('Class 8')) {
      return ['Mathematics', 'Science', 'English', 'Social Studies'];
    } else if (selectedClass.value.contains('Class 9') ||
        selectedClass.value.contains('Class 10')) {
      return [
        'Mathematics',
        'Science',
        'Physics',
        'Chemistry',
        'Biology',
        'English',
        'Social Studies',
      ];
    } else if (selectedClass.value.contains('Class 11') ||
        selectedClass.value.contains('Class 12')) {
      return [
        'Physics',
        'Chemistry',
        'Mathematics',
        'Biology',
        'Computer Science',
        'Economics',
        'History',
      ];
    } else {
      return [
        'Computer Science',
        'Physics',
        'Chemistry',
        'Biology',
        'Mathematics',
        'Engineering',
      ];
    }
  }

  List<String> get topics {
    if (selectedSubject.value.isEmpty) return [];

    switch (selectedSubject.value) {
      case 'Mathematics':
        if (selectedClass.value.contains('Class 6') ||
            selectedClass.value.contains('Class 7') ||
            selectedClass.value.contains('Class 8')) {
          return [
            'Numbers',
            'Algebraic Expressions',
            'Geometry',
            'Mensuration',
            'Data Handling',
          ];
        } else if (selectedClass.value.contains('Class 9') ||
            selectedClass.value.contains('Class 10')) {
          return [
            'Number Systems',
            'Polynomials',
            'Linear Equations',
            'Triangles',
            'Trigonometry',
          ];
        } else {
          return [
            'Calculus',
            'Algebra',
            'Differential Equations',
            'Probability',
            'Statistics',
          ];
        }

      case 'Science':
        return [
          'Chemical Reactions',
          'Human Body',
          'Light and Sound',
          'Electricity',
        ];

      case 'Physics':
        return [
          'Mechanics',
          'Thermodynamics',
          'Electromagnetism',
          'Optics',
          'Modern Physics',
        ];

      case 'Chemistry':
        return [
          'Atomic Structure',
          'Chemical Bonding',
          'Thermodynamics',
          'Organic Chemistry',
          'Physical Chemistry',
        ];

      case 'Biology':
        return [
          'Cell Biology',
          'Genetics',
          'Human Physiology',
          'Ecology',
          'Plant Biology',
        ];

      case 'Computer Science':
        return [
          'Programming',
          'Data Structures',
          'Algorithms',
          'Database Management',
        ];

      case 'English':
        return ['Grammar', 'Literature', 'Comprehension', 'Writing Skills'];

      case 'Social Studies':
        return ['History', 'Geography', 'Civics', 'Economics'];

      case 'Economics':
        return ['Microeconomics', 'Macroeconomics', 'Indian Economy'];

      case 'History':
        return [
          'Ancient History',
          'Medieval History',
          'Modern History',
          'World History',
        ];

      default:
        return ['General Topic 1', 'General Topic 2', 'General Topic 3'];
    }
  }

  List<String> get subtopics {
    if (selectedTopic.value.isEmpty) return [];

    switch (selectedTopic.value) {
      case 'Calculus':
        return [
          'Limits and Continuity',
          'Derivatives',
          'Integration',
          'Differential Equations',
        ];

      case 'Algebra':
        return [
          'Linear Equations',
          'Matrices and Determinants',
          'Vector Algebra',
        ];

      case 'Programming':
        return [
          'Variables and Data Types',
          'Control Structures',
          'Functions',
          'Object-Oriented Programming',
        ];

      case 'Data Structures':
        return [
          'Arrays',
          'Linked Lists',
          'Stacks',
          'Queues',
          'Trees',
          'Graphs',
        ];

      case 'Mechanics':
        return [
          'Laws of Motion',
          'Work, Energy, and Power',
          'Gravitation',
          'Rotational Motion',
        ];

      case 'Atomic Structure':
        return ['Bohr Model', 'Quantum Mechanical Model', 'Periodic Trends'];

      case 'Cell Biology':
        return [
          'Cell Structure and Organelles',
          'Cell Division',
          'Photosynthesis',
          'Cellular Respiration',
        ];

      case 'Human Physiology':
        return [
          'Digestive System',
          'Circulatory System',
          'Nervous System',
          'Endocrine System',
        ];

      case 'Thermodynamics':
        return [
          'Laws of Thermodynamics',
          'Heat and Temperature',
          'Thermodynamic Processes',
        ];

      default:
        return [
          'General Subtopic 1',
          'General Subtopic 2',
          'General Subtopic 3',
        ];
    }
  }

  // Event handlers for dropdown changes
  void onClassChanged(String? value) {
    selectedClass.value = value ?? '';
    selectedSubject.value = '';
    selectedTopic.value = '';
    selectedSubtopic.value = '';
    _resetQuiz();
  }

  void onSubjectChanged(String? value) {
    selectedSubject.value = value ?? '';
    selectedTopic.value = '';
    selectedSubtopic.value = '';
    _resetQuiz();
  }

  void onTopicChanged(String? value) {
    selectedTopic.value = value ?? '';
    selectedSubtopic.value = '';
    _resetQuiz();
  }

  void onSubtopicChanged(String? value) {
    selectedSubtopic.value = value ?? '';
    _resetQuiz();
  }

  // Validation method
  bool canGenerateQuiz() {
    return selectedClass.value.isNotEmpty &&
        selectedSubject.value.isNotEmpty &&
        selectedTopic.value.isNotEmpty &&
        selectedSubtopic.value.isNotEmpty;
  }

  // Generate quiz with structured parameters
  Future<void> generateQuiz() async {
    if (!canGenerateQuiz()) {
      Get.snackbar(
        "Incomplete Selection",
        "Please select all fields to generate quiz",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return;
    }

    isLoading.value = true;
    quizStarted.value = false;
    quizCompleted.value = false;

    try {
      // Create structured topic string
      String structuredTopic = _buildQuizContext();
      print('Generating quiz for: $structuredTopic');

      // Generate quiz - check if your repository supports these parameters
      Quiz quiz;
      try {
        // Try with additional parameters first
        quiz = await _repository.generateQuiz(
          structuredTopic,
          numberOfQuestions: numberOfQuestions.value,
          difficulty: difficulty.value,
        );
        print('Quiz generated with advanced parameters $quiz');
      } catch (e) {
        // Fallback to basic method if repository doesn't support additional parameters
        print('Error with advanced generation: $e');
        quiz = await _repository.generateQuiz(structuredTopic);
      }

      questions.value = quiz.questions;
      currentQuestionIndex.value = 0;
      score.value = 0;
      selectedAnswers.clear();
      correctAnswers.clear();

      // Initialize answer tracking
      for (int i = 0; i < questions.length; i++) {
        selectedAnswers.add('');
        correctAnswers.add(false);
      }

      quizStarted.value = true;

      Get.snackbar(
        "Quiz Ready!",
        "Generated ${questions.length} questions on ${selectedSubtopic.value}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate quiz: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      print('Quiz generation error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Build context string for API
  String _buildQuizContext() {
    return '${selectedClass.value} ${selectedSubject.value} - ${selectedTopic.value} - ${selectedSubtopic.value}';
  }

  // Enhanced answer handling
  void answerQuestion(String answer) {
    if (currentQuestionIndex.value >= questions.length) return;

    final currentQuestion = questions[currentQuestionIndex.value];
    final isCorrect = currentQuestion.answer == answer;

    // Store the selected answer
    selectedAnswers[currentQuestionIndex.value] = answer;
    correctAnswers[currentQuestionIndex.value] = isCorrect;

    if (isCorrect) {
      score.value++;
    }

    // Move to next question or finish quiz
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      _finishQuiz();
    }
  }

  // Finish quiz with detailed results - shows results screen first
  void _finishQuiz() {
    quizCompleted.value = true;

    final percentage = (score.value / questions.length * 100).round();
    String message = _getScoreMessage(percentage);

    // Show completion snackbar
    Get.snackbar(
      "Quiz Completed! 🎉",
      "$message\nScore: ${score.value}/${questions.length} ($percentage%)",
      snackPosition: SnackPosition.TOP,
      backgroundColor: _getScoreColor(percentage).withOpacity(0.1),
      colorText: _getScoreColor(percentage),
      duration: const Duration(seconds: 3),
    );

    // Auto-navigate back to quiz selection after delay if enabled
    if (autoNavigateToHome.value) {
      _scheduleNavigationToHome();
    }
  }

  // Schedule navigation back to quiz selection (home screen)
  void _scheduleNavigationToHome() {
    Future.delayed(Duration(seconds: navigationDelay.value), () {
      if (quizCompleted.value) {
        backToSelection(); // This will reset and show quiz input screen
      }
    });
  }

  // Navigate to home screen/widget - REMOVED since we're staying in same screen
  void navigateToHome() {
    // Instead of navigating away, just go back to selection
    backToSelection();
  }

  // Manual navigation to home (for button press)
  void goToHome() {
    backToSelection();
  }

  // Get motivational message based on score
  String _getScoreMessage(int percentage) {
    if (percentage >= 90) return "Excellent! Outstanding performance!";
    if (percentage >= 80) return "Great job! Well done!";
    if (percentage >= 70) return "Good work! Keep it up!";
    if (percentage >= 60) return "Not bad! Room for improvement!";
    return "Keep practicing! You'll get better!";
  }

  // Get color based on score
  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50); // Green
    if (percentage >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  // Reset quiz state
  void _resetQuiz() {
    questions.clear();
    currentQuestionIndex.value = 0;
    score.value = 0;
    quizStarted.value = false;
    quizCompleted.value = false;
    selectedAnswers.clear();
    correctAnswers.clear();
  }

  // Restart quiz with same parameters
  void restartQuiz() {
    if (canGenerateQuiz()) {
      // Reset completion state but keep selections
      quizCompleted.value = false;
      generateQuiz();
    }
  }

  // Go back to quiz selection (this is our "home" screen)
  void backToSelection() {
    _resetQuiz();

    // Show welcome back message after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.snackbar(
        "Ready for Another Quiz? 🎯",
        "Select your preferences to generate a new quiz",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
        duration: const Duration(seconds: 2),
      );
    });
  }

  // Navigation helpers
  void goToPreviousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  // Get quiz progress
  double get progress {
    if (questions.isEmpty) return 0.0;
    return (currentQuestionIndex.value + 1) / questions.length;
  }

  // Get current question
  Question? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex.value >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex.value];
  }

  // Check if answer is selected for current question
  bool get isAnswerSelected {
    if (currentQuestionIndex.value >= selectedAnswers.length) return false;
    return selectedAnswers[currentQuestionIndex.value].isNotEmpty;
  }

  // Get quiz summary
  Map<String, dynamic> get quizSummary {
    return {
      'totalQuestions': questions.length,
      'correctAnswers': score.value,
      'incorrectAnswers': questions.length - score.value,
      'percentage': questions.isNotEmpty
          ? (score.value / questions.length * 100).round()
          : 0,
      'class': selectedClass.value,
      'subject': selectedSubject.value,
      'topic': selectedTopic.value,
      'subtopic': selectedSubtopic.value,
      'difficulty': difficulty.value,
    };
  }

  // Settings for auto-navigation
  void setAutoNavigateToHome(bool enabled) {
    autoNavigateToHome.value = enabled;
  }

  void setNavigationDelay(int seconds) {
    if (seconds >= 1 && seconds <= 10) {
      navigationDelay.value = seconds;
    }
  }

  // Disable auto-navigation (for manual control)
  void disableAutoNavigation() {
    autoNavigateToHome.value = false;
  }

  // Enable auto-navigation
  void enableAutoNavigation() {
    autoNavigateToHome.value = true;
  }

  // Check if currently showing results
  bool get isShowingResults {
    return quizCompleted.value && questions.isNotEmpty;
  }

  // Check if quiz is in progress
  bool get isQuizInProgress {
    return quizStarted.value && !quizCompleted.value && questions.isNotEmpty;
  }

  // Check if showing quiz input screen
  bool get isShowingQuizInput {
    return !quizStarted.value && questions.isEmpty && !isLoading.value;
  }

  // Get performance level based on percentage
  String getPerformanceLevel(int percentage) {
    if (percentage >= 90) return "Excellent";
    if (percentage >= 80) return "Very Good";
    if (percentage >= 70) return "Good";
    if (percentage >= 60) return "Average";
    return "Needs Improvement";
  }

  // Get quiz difficulty color
  Color getDifficultyColor() {
    switch (difficulty.value) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return const Color(0xFF667eea);
    }
  }

  // Legacy method for backward compatibility
  Future<void> loadQuiz(String topic) async {
    isLoading.value = true;
    try {
      // Use the basic generateQuiz method for legacy support
      Quiz quiz = await _repository.generateQuiz(topic);
      questions.value = quiz.questions;
      currentQuestionIndex.value = 0;
      score.value = 0;
      selectedAnswers.clear();
      correctAnswers.clear();

      // Initialize answer tracking
      for (int i = 0; i < questions.length; i++) {
        selectedAnswers.add('');
        correctAnswers.add(false);
      }

      quizStarted.value = true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up resources
    _resetQuiz();
    super.onClose();
  }
}
