import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/game_state.dart';

/// Service that manages the WebSocket connection to the server and provides
/// real-time game state updates.
class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  GameState? _gameState;
  bool _isAdmin = false;
  bool _isConnected = false;
  String? _error;
  Timer? _reconnectTimer;
  String? _url;

  GameState? get gameState => _gameState;
  bool get isAdmin => _isAdmin;
  bool get isConnected => _isConnected;
  String? get error => _error;

  /// Connects to the WebSocket server at the given URL.
  void connect(String url) {
    _url = url;
    _error = null;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          _handleMessage(message as String);
        },
        onDone: () {
          _isConnected = false;
          _isAdmin = false;
          notifyListeners();
          _scheduleReconnect();
        },
        onError: (error) {
          _isConnected = false;
          _isAdmin = false;
          _error = 'Connection error: $error';
          notifyListeners();
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      _error = 'Failed to connect: $e';
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_url != null && !_isConnected) {
        connect(_url!);
      }
    });
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String;

      switch (type) {
        case 'state_update':
          _gameState =
              GameState.fromJson(data['data'] as Map<String, dynamic>);
          _error = null;
          notifyListeners();
          break;
        case 'auth_response':
          _isAdmin = data['success'] as bool;
          if (!_isAdmin) {
            _error = 'Authentication failed. Incorrect password.';
          } else {
            _error = null;
          }
          notifyListeners();
          break;
        case 'error':
          _error = data['message'] as String;
          notifyListeners();
          break;
      }
    } catch (e) {
      _error = 'Error processing message: $e';
      notifyListeners();
    }
  }

  /// Sends an authentication request with the given password.
  void authenticate(String password) {
    _send({'type': 'auth', 'password': password});
  }

  /// Updates all player scores at once.
  void updateAllScores(List<Map<String, dynamic>> playerUpdates) {
    _send({
      'type': 'update_scores',
      'players': playerUpdates,
    });
  }

  /// Updates a single player's details.
  void updatePlayer(String id, {String? name, String? photoUrl, int? points}) {
    final data = <String, dynamic>{'type': 'update_player', 'id': id};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (points != null) data['points'] = points;
    _send(data);
  }

  /// Sets the current round number.
  void setRound(int round) {
    _send({'type': 'set_round', 'round': round});
  }

  /// Resets all scores and sets the round back to 1.
  void resetScores() {
    _send({'type': 'reset_scores'});
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
