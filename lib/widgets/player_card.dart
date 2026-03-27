import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_state.dart';

/// A card widget that displays a player inside a gold picture frame
/// with their score shown in a red wax seal below, matching the
/// Taskmaster TV show scoreboard aesthetic.
class PlayerCard extends StatelessWidget {
  final Player player;
  final int rank;
  final int totalPlayers;
  final double availableWidth;

  const PlayerCard({
    super.key,
    required this.player,
    required this.rank,
    required this.totalPlayers,
    required this.availableWidth,
  });

  // Layout constants
  static const double _maxCardWidth = 220.0;
  static const double _horizontalPadding = 40.0;
  static const double _frameSizeRatio = 0.85;
  static const double _sealToFrameRatio = 0.55;
  static const double _sealOverlapRatio = 0.1;
  static const double _frameContentPaddingRatio = 0.16;

  @override
  Widget build(BuildContext context) {
    // Calculate sizing based on available width and number of players
    final cardWidth = min(
      _maxCardWidth,
      (availableWidth - _horizontalPadding) / max(totalPlayers, 1),
    );
    final frameSize = cardWidth * _frameSizeRatio;
    final sealSize = frameSize * _sealToFrameRatio;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gold picture frame with player name/photo inside
          _buildFrame(frameSize),
          // Red wax seal with score, slightly overlapping the frame
          Transform.translate(
            offset: Offset(0, -sealSize * _sealOverlapRatio),
            child: _buildSeal(sealSize),
          ),
        ],
      ),
    );
  }

  /// Builds the gold picture frame containing the player's photo or name.
  Widget _buildFrame(double size) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Player content inside the frame (positioned behind the frame)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(size * _frameContentPaddingRatio),
              child: _buildPlayerContent(),
            ),
          ),
          // Gold frame overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/frame.png',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the player content that goes inside the frame.
  Widget _buildPlayerContent() {
    if (player.photoUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          image: DecorationImage(
            image: NetworkImage(player.photoUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              player.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Courier New',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    // Default: show player initial on grey background (like reference X placeholders)
    return Container(
      color: Colors.grey.shade400,
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : 'X',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier New',
            color: Colors.white.withValues(alpha: 0.8),
            shadows: const [
              Shadow(
                color: Color(0x60000000),
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the red wax seal displaying the player's score.
  Widget _buildSeal(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Seal image
          Positioned.fill(
            child: Image.asset(
              'assets/images/seal.png',
              fit: BoxFit.contain,
            ),
          ),
          // Score text on top of the seal
          Text(
            '${player.points}',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
              color: Colors.white.withValues(alpha: 0.9),
              shadows: const [
                Shadow(
                  color: Color(0x80000000),
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
