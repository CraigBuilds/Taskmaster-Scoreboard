import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/websocket_service.dart';
import '../widgets/player_card.dart';

/// The main scoreboard display screen, intended for the big screen view.
/// Shows all players ordered by their points (highest first).
class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      body: Consumer<WebSocketService>(
        builder: (context, service, child) {
          if (!service.isConnected) {
            return const Center(
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
            );
          }

          final gameState = service.gameState;
          if (gameState == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE6B800),
              ),
            );
          }

          final sortedPlayers = gameState.sortedPlayers;

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TASKMASTER',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE6B800),
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: Color(0x80E6B800),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ROUND ${gameState.currentRound}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              // Player list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    return PlayerCard(
                      player: sortedPlayers[index],
                      rank: index + 1,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
