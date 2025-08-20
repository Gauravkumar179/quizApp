import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy leaderboard data
    final leaderboard = [
      {
        "name": "Alice",
        "score": 980,
        "photo": "https://i.pravatar.cc/150?img=1", // random dummy avatar
      },
      {"name": "Bob", "score": 870, "photo": "https://i.pravatar.cc/150?img=2"},
      {
        "name": "Charlie",
        "score": 750,
        "photo": "https://i.pravatar.cc/150?img=3",
      },
      {
        "name": "Diana",
        "score": 690,
        "photo": "https://i.pravatar.cc/150?img=4",
      },
      {
        "name": "Ethan",
        "score": 650,
        "photo": "https://i.pravatar.cc/150?img=5",
      },
    ];

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
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Leaderboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Top 3 podium
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPodiumItem(2, leaderboard[1]),
                  _buildPodiumItem(1, leaderboard[0]),
                  _buildPodiumItem(3, leaderboard[2]),
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
                    itemCount: leaderboard.length - 3,
                    itemBuilder: (context, index) {
                      final player = leaderboard[index + 3];
                      final rank = index + 4;
                      return _buildLeaderboardItem(rank, player);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumItem(int rank, Map<String, dynamic> player) {
    final colors = {1: Colors.amber, 2: Colors.grey, 3: Colors.brown};
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: NetworkImage(player["photo"]),
        ),
        const SizedBox(height: 8),
        Text(
          player["name"],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "${player["score"]} pts",
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

  Widget _buildLeaderboardItem(int rank, Map<String, dynamic> player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          CircleAvatar(backgroundImage: NetworkImage(player["photo"])),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player["name"],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          Text(
            "${player["score"]} pts",
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
