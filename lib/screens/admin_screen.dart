import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/websocket_service.dart';
import '../widgets/player_score_editor.dart';

/// The admin screen where the Taskmaster's assistant can log in,
/// edit player scores, and trigger updates to the display view.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _login(WebSocketService service) {
    setState(() => _isLoggingIn = true);
    service.authenticate(_passwordController.text);
    // The auth response will update isAdmin via the service
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFFE6B800),
        actions: [
          // Link to display view
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            icon: const Icon(Icons.tv, color: Colors.white70),
            label: const Text(
              'Display View',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Consumer<WebSocketService>(
        builder: (context, service, child) {
          if (!service.isConnected) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE6B800)),
                  SizedBox(height: 24),
                  Text(
                    'Connecting to server...',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (!service.isAdmin) {
            return _buildLoginView(service);
          }

          return _buildAdminView(service);
        },
      ),
    );
  }

  Widget _buildLoginView(WebSocketService service) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Color(0xFFE6B800),
            ),
            const SizedBox(height: 24),
            const Text(
              'Admin Login',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFE6B800)),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.white54),
              ),
              onSubmitted: (_) => _login(service),
            ),
            const SizedBox(height: 16),
            if (service.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  service.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoggingIn ? null : () => _login(service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6B800),
                  foregroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoggingIn
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1A1A2E),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminView(WebSocketService service) {
    final gameState = service.gameState;
    if (gameState == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE6B800)),
      );
    }

    return Column(
      children: [
        // Round controls
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A1A2E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Round: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Color(0xFFE6B800)),
                iconSize: 32,
                onPressed: gameState.currentRound > 1
                    ? () =>
                        service.setRound(gameState.currentRound - 1)
                    : null,
              ),
              Text(
                '${gameState.currentRound}',
                style: const TextStyle(
                  color: Color(0xFFE6B800),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFFE6B800)),
                iconSize: 32,
                onPressed: () =>
                    service.setRound(gameState.currentRound + 1),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _confirmReset(context, service),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Player editors
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: gameState.players.length,
            itemBuilder: (context, index) {
              final player = gameState.players[index];
              return PlayerScoreEditor(
                key: ValueKey(player.id),
                player: player,
                onPointsChanged: (points) {
                  service.updatePlayer(player.id, points: points);
                },
                onNameChanged: (name) {
                  service.updatePlayer(player.id, name: name);
                },
              );
            },
          ),
        ),
        // Connection status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF1A1A2E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: service.isConnected ? Colors.greenAccent : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                service.isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: service.isConnected ? Colors.greenAccent : Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, WebSocketService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Reset All Scores?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will set all player scores to 0 and reset the round to 1.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              service.resetScores();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child:
                const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
