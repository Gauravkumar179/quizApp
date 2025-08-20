import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizapp/views/live_quiz_page.dart';
import '../viewmodels/quiz_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final quizVM = Get.find<QuizViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (quizVM.isLoading.value) {
              return _buildLoadingState();
            }
            return _buildQuizInputState(quizVM);
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  'Generating your quiz...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few moments',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInputState(QuizViewModel quizVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Header Section
          const LiveQuizSlider(),

          const SizedBox(height: 10),

          // Quick Start Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Start',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickStartOption(
                  'Mathematics Quiz',
                  'Class 10 • Algebra',
                  Icons.calculate,
                  () => _startQuickQuiz(
                    quizVM,
                    'Class 10',
                    'Mathematics',
                    'Algebra',
                    'Linear Equations',
                  ),
                ),
                _buildQuickStartOption(
                  'Science Quiz',
                  'Class 9 • Physics',
                  Icons.science,
                  () => _startQuickQuiz(
                    quizVM,
                    'Class 9',
                    'Science',
                    'Physics',
                    'Motion',
                  ),
                ),
                _buildQuickStartOption(
                  'Computer Science',
                  'Class 12 • Programming',
                  Icons.computer,
                  () => _startQuickQuiz(
                    quizVM,
                    'Class 12',
                    'Computer Science',
                    'Programming',
                    'Arrays',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quiz Configuration Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Quiz Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 24),

                // Class Dropdown
                _buildDropdownField(
                  label: 'Class',
                  icon: Icons.school,
                  value: quizVM.selectedClass.value,
                  items: quizVM.classes,
                  onChanged: (value) => quizVM.onClassChanged(value),
                  hint: 'Select your class',
                ),

                const SizedBox(height: 20),

                // Subject Dropdown
                _buildDropdownField(
                  label: 'Subject',
                  icon: Icons.book,
                  value: quizVM.selectedSubject.value,
                  items: quizVM.subjects,
                  onChanged: quizVM.selectedClass.value.isNotEmpty
                      ? (value) => quizVM.onSubjectChanged(value)
                      : null,
                  hint: 'Select subject',
                ),

                const SizedBox(height: 20),

                // Topic Dropdown
                _buildDropdownField(
                  label: 'Topic',
                  icon: Icons.topic,
                  value: quizVM.selectedTopic.value,
                  items: quizVM.topics,
                  onChanged: quizVM.selectedSubject.value.isNotEmpty
                      ? (value) => quizVM.onTopicChanged(value)
                      : null,
                  hint: 'Select topic',
                ),

                const SizedBox(height: 20),

                // Subtopic Dropdown
                _buildDropdownField(
                  label: 'Subtopic',
                  icon: Icons.subdirectory_arrow_right,
                  value: quizVM.selectedSubtopic.value,
                  items: quizVM.subtopics,
                  onChanged: quizVM.selectedTopic.value.isNotEmpty
                      ? (value) => quizVM.onSubtopicChanged(value)
                      : null,
                  hint: 'Select subtopic',
                ),

                const SizedBox(height: 32),

                // Quiz Settings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quiz Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Number of Questions
                      Row(
                        children: [
                          const Icon(
                            Icons.format_list_numbered,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Number of Questions: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Obx(
                              () => Text(
                                '${quizVM.numberOfQuestions.value}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Slider(
                          value: quizVM.numberOfQuestions.value.toDouble(),
                          min: 5,
                          max: 20,
                          divisions: 15,
                          activeColor: const Color(0xFF667eea),
                          onChanged: (value) =>
                              quizVM.numberOfQuestions.value = value.toInt(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Difficulty Level
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Difficulty: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Obx(
                            () => DropdownButton<String>(
                              value: quizVM.difficulty.value,
                              underline: const SizedBox(),
                              items: ['Easy', 'Medium', 'Hard'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(
                                        value,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getDifficultyColor(value),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  quizVM.difficulty.value = value!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Generate Quiz Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: quizVM.canGenerateQuiz()
                          ? () => quizVM.generateQuiz()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            quizVM.canGenerateQuiz()
                                ? 'Generate Custom Quiz'
                                : 'Please select all fields',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Features Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.auto_awesome,
                  'AI-Powered',
                  'Smart questions generated by advanced AI',
                ),
                _buildFeatureItem(
                  Icons.tune,
                  'Customizable',
                  'Adjust difficulty and question count',
                ),
                _buildFeatureItem(
                  Icons.speed,
                  'Instant Results',
                  'Get immediate feedback on answers',
                ),
                _buildFeatureItem(
                  Icons.trending_up,
                  'Track Progress',
                  'Monitor your learning journey',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF667eea), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF667eea),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickQuiz(
    QuizViewModel quizVM,
    String className,
    String subject,
    String topic,
    String subtopic,
  ) {
    quizVM.selectedClass.value = className;
    quizVM.selectedSubject.value = subject;
    quizVM.selectedTopic.value = topic;
    quizVM.selectedSubtopic.value = subtopic;
    quizVM.generateQuiz();
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    required String hint,
  }) {
    // Ensure unique items
    final uniqueItems = items.toSet().toList();

    // Ensure selected value exists in list, otherwise set null
    final safeValue = uniqueItems.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onChanged != null ? Colors.grey[300]! : Colors.grey[200]!,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: safeValue, // ✅ prevents crash
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
            dropdownColor: Colors.white,
            items: uniqueItems.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF667eea),
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
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

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF667eea), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
