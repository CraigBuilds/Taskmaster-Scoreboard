import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/websocket_service.dart';
import '../widgets/player_card.dart';

/// The main scoreboard display screen, intended for the big screen view.
/// Shows all players ordered by their points (highest first).
/// Styled to look like the Taskmaster TV show scoreboard with a typewriter
/// background, gold picture frames, and red wax seal scores.
class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WebSocketService>(
        builder: (context, service, child) {
          if (!service.isConnected) {
            return _buildBackground(
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFE6B800),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Connecting to server...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final gameState = service.gameState;
          if (gameState == null) {
            return _buildBackground(
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE6B800),
                ),
              ),
            );
          }

          final sortedPlayers = gameState.sortedPlayers;

          return _buildBackground(
            child: Column(
              children: [
                // Header with TASKMASTER title
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 8),
                  child: Text(
                    'TASKMASTER',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Courier New',
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 12,
                      shadows: const [
                        Shadow(
                          color: Color(0x80000000),
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Players displayed horizontally with frames and seals
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: sortedPlayers.map((player) {
                              return PlayerCard(
                                player: player,
                                rank: sortedPlayers.indexOf(player) + 1,
                                totalPlayers: sortedPlayers.length,
                                availableWidth: constraints.maxWidth,
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the background with the typewriter image.
  Widget _buildBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: child,
    );
  }
}
