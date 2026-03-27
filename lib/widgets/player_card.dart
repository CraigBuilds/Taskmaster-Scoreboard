import 'package:flutter/material.dart';

import '../models/game_state.dart';

/// A card widget that displays a player's rank, avatar, name, and score
/// on the scoreboard display view.
class PlayerCard extends StatelessWidget {
  final Player player;
  final int rank;

  const PlayerCard({
    super.key,
    required this.player,
    required this.rank,
  });

  /// Returns a color based on the player's rank.
  Color _rankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF4A4A6A); // Dark purple-grey
    }
  }

  /// Returns a background color for the player's avatar based on their ID.
  Color _avatarColor() {
    final colors = [
      const Color(0xFFE53935), // Red
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF43A047), // Green
      const Color(0xFF8E24AA), // Purple
      const Color(0xFFFB8C00), // Orange
    ];
    final index = int.tryParse(player.id) ?? 0;
    return colors[(index - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _rankColor().withValues(alpha: 0.5),
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _rankColor().withValues(alpha: 0.2),
            blurRadius: rank <= 3 ? 12 : 4,
            spreadRadius: rank <= 3 ? 2 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 48,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _rankColor(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Player avatar
            _buildAvatar(),
            const SizedBox(width: 20),
            // Player name
            Expanded(
              child: Text(
                player.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _rankColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _rankColor().withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${player.points}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _rankColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (player.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(player.photoUrl),
        backgroundColor: _avatarColor(),
      );
    }
    return CircleAvatar(
      radius: 30,
      backgroundColor: _avatarColor(),
      child: Text(
        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
