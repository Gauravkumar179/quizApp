import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/live_quiz_model.dart';
import '../services/live_quiz_service.dart';

// 1. Create a GetX Controller
class LiveQuizLeaderboardController extends GetxController {
  final LiveQuiz quiz;
  final int userScore;
  final leaderboard = <LeaderboardEntry>[].obs;
  late final LiveQuizService _quizService;

  LiveQuizLeaderboardController({required this.quiz, required this.userScore});

  @override
  void onInit() {
    super.onInit();
    _quizService = LiveQuizService();
    // Subscribe to the Firestore stream and update the reactive list
    leaderboard.bindStream(_quizService.getLeaderboard(quiz.quizId));
  }
}

class LiveQuizLeaderboardPage extends StatelessWidget {
  final LiveQuiz quiz;
  final int userScore;

  const LiveQuizLeaderboardPage({
    super.key,
    required this.quiz,
    required this.userScore,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Instantiate the controller using Get.put()
    final LiveQuizLeaderboardController controller = Get.put(
      LiveQuizLeaderboardController(quiz: quiz, userScore: userScore),
    );
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      quiz.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Score: $userScore pts',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Use Obx to rebuild when the leaderboard data changes
              Obx(() {
                if (controller.leaderboard.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No participants yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final topPlayers = controller.leaderboard.take(3).toList();
                final otherPlayers = controller.leaderboard.skip(3).toList();

                return Expanded(
                  child: Column(
                    children: [
                      // Top 3 podium
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (topPlayers.length > 1)
                            _buildPodiumItem(2, topPlayers[1], context),
                          if (topPlayers.isNotEmpty)
                            _buildPodiumItem(1, topPlayers[0], context),
                          if (topPlayers.length > 2)
                            _buildPodiumItem(3, topPlayers[2], context),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // List of other players
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: otherPlayers.length,
                            itemBuilder: (context, index) {
                              final player = otherPlayers[index];
                              final rank = index + 4;
                              final isCurrentUser =
                                  currentUser != null &&
                                  player.uid == currentUser.uid;
                              return _buildLeaderboardItem(
                                rank,
                                player,
                                isCurrentUser,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumItem(
    int rank,
    LeaderboardEntry player,
    BuildContext context,
  ) {
    final colors = {1: Colors.amber, 2: Colors.grey, 3: Colors.brown};
    final isCurrentUser =
        FirebaseAuth.instance.currentUser != null &&
        player.uid == FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: player.photoUrl != null
                  ? NetworkImage(player.photoUrl!)
                  : null,
              child: player.photoUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            if (isCurrentUser)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          player.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${player.points} pts",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors[rank],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "#$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    LeaderboardEntry player,
    bool isCurrentUser,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.blue : Colors.grey[200]!,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            "#$rank",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: player.photoUrl != null
                ? NetworkImage(player.photoUrl!)
                : null,
            child: player.photoUrl == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "${player.points} pts",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
