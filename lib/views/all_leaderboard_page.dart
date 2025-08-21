import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/live_quiz_model.dart';
import '../services/live_quiz_service.dart';
import 'live_quiz_leaderboard_page.dart.dart';

class AllLeaderboardsPage extends StatelessWidget {
  const AllLeaderboardsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.leaderboard,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leaderboards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width < 360
                                  ? 20
                                  : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'View rankings for all quizzes',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: MediaQuery.of(context).size.width < 360
                                  ? 14
                                  : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildLeaderboardContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(BuildContext context) {
    return StreamBuilder<List<LiveQuiz>>(
      stream: LiveQuizService().getLiveQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.leaderboard,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Quiz Leaderboards Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete live quizzes to see leaderboards here',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final quizzes = snapshot.data!;

        return Column(
          children: [
            // My Rankings Summary
            _buildMyRankingsSummary(context),

            // Quiz Leaderboards List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                  vertical: 16,
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return _buildQuizLeaderboardCard(context, quiz);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyRankingsSummary(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leaderboard')
          .where('uid', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final userEntries = snapshot.data!.docs;
        final totalPoints = userEntries.fold<int>(
          0,
          (sum, doc) =>
              sum + (doc.data() as Map<String, dynamic>)['points'] as int,
        );
        final totalQuizzes = userEntries.length;
        final averageScore = totalQuizzes > 0
            ? (totalPoints / totalQuizzes).round()
            : 0;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06,
            vertical: 16,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'My Performance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width < 360
                            ? 16
                            : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use different layouts based on available width
                  if (constraints.maxWidth < 200) {
                    // Stack vertically on very small screens
                    return Column(
                      children: [
                        _buildStatItem(
                          context,
                          'Total Points',
                          '$totalPoints',
                          Icons.stars,
                        ),
                        const SizedBox(height: 12),
                        _buildStatItem(
                          context,
                          'Quizzes Taken',
                          '$totalQuizzes',
                          Icons.quiz,
                        ),
                        const SizedBox(height: 12),
                        _buildStatItem(
                          context,
                          'Avg Score',
                          '$averageScore',
                          Icons.trending_up,
                        ),
                      ],
                    );
                  } else {
                    // Use row layout for larger screens
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              'Total Points',
                              '$totalPoints',
                              Icons.stars,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              'Quizzes Taken',
                              '$totalQuizzes',
                              Icons.quiz,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              'Avg Score',
                              '$averageScore',
                              Icons.trending_up,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: MediaQuery.of(context).size.width < 360 ? 10 : 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuizLeaderboardCard(BuildContext context, LiveQuiz quiz) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: LiveQuizService().getLeaderboard(quiz.quizId),
      builder: (context, leaderboardSnapshot) {
        final participantCount = leaderboardSnapshot.hasData
            ? leaderboardSnapshot.data!.length
            : 0;

        final topScorer =
            leaderboardSnapshot.hasData && leaderboardSnapshot.data!.isNotEmpty
            ? leaderboardSnapshot.data!.first
            : null;

        final currentUser = FirebaseAuth.instance.currentUser;
        final userEntry = leaderboardSnapshot.hasData
            ? leaderboardSnapshot.data!
                  .where((entry) => entry.uid == currentUser?.uid)
                  .firstOrNull
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: participantCount > 0
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LiveQuizLeaderboardPage(
                          quiz: quiz,
                          userScore: userEntry?.points ?? 0,
                        ),
                      ),
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getQuizStatusColor(quiz).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.quiz,
                          color: _getQuizStatusColor(quiz),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.title,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 360
                                    ? 12
                                    : 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quiz.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildQuizStatusBadge(quiz),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats Row - Make responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            Icons.people,
                            '$participantCount participants',
                            Colors.blue,
                          ),
                          _buildInfoChip(
                            Icons.help,
                            '${quiz.totalQuestions} questions',
                            Colors.orange,
                          ),
                          _buildInfoChip(
                            Icons.trending_up,
                            quiz.difficulty,
                            _getDifficultyColor(quiz.difficulty),
                          ),
                        ],
                      );
                    },
                  ),

                  if (participantCount > 0) ...[
                    const SizedBox(height: 16),

                    // Top Scorer & User Position - Make responsive
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 300) {
                          // Stack vertically on small screens
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (topScorer != null) ...[
                                _buildTopScorerSection(topScorer),
                                if (userEntry != null)
                                  const SizedBox(height: 12),
                              ],
                              if (userEntry != null)
                                _buildUserPositionSection(
                                  context,
                                  leaderboardSnapshot.data!,
                                  userEntry,
                                ),
                            ],
                          );
                        } else {
                          // Use row layout for larger screens
                          return Row(
                            children: [
                              if (topScorer != null) ...[
                                Expanded(
                                  flex: 2,
                                  child: _buildTopScorerSection(topScorer),
                                ),
                              ],
                              if (userEntry != null) ...[
                                if (topScorer != null)
                                  const SizedBox(width: 16),
                                Flexible(
                                  child: _buildUserPositionSection(
                                    context,
                                    leaderboardSnapshot.data!,
                                    userEntry,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No participants yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopScorerSection(LeaderboardEntry topScorer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Scorer',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: topScorer.photoUrl != null
                  ? NetworkImage(topScorer.photoUrl!)
                  : null,
              child: topScorer.photoUrl == null
                  ? const Icon(Icons.person, size: 12)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${topScorer.name} - ${topScorer.points} pts',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserPositionSection(
    BuildContext context,
    List<LeaderboardEntry> leaderboard,
    LeaderboardEntry userEntry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Your Position',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            child: Text(
              '#${_getUserRank(leaderboard, userEntry)} - ${userEntry.points} pts',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStatusBadge(LiveQuiz quiz) {
    String status;
    Color color;

    if (quiz.isLive) {
      status = 'LIVE';
      color = Colors.red;
    } else if (quiz.isUpcoming) {
      status = 'UPCOMING';
      color = Colors.orange;
    } else {
      status = 'ENDED';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quiz.isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQuizStatusColor(LiveQuiz quiz) {
    if (quiz.isLive) return Colors.red;
    if (quiz.isUpcoming) return Colors.orange;
    return Colors.grey;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _getUserRank(
    List<LeaderboardEntry> leaderboard,
    LeaderboardEntry userEntry,
  ) {
    return leaderboard.indexWhere((entry) => entry.uid == userEntry.uid) + 1;
  }
}
