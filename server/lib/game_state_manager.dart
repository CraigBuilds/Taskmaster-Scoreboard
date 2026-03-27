import 'dart:convert';

/// Represents a player/contestant in the Taskmaster game (server-side).
class Player {
  String id;
  String name;
  String photoUrl;
  int points;

  Player({
    required this.id,
    required this.name,
    this.photoUrl = '',
    this.points = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'points': points,
      };
}

/// Manages the game state on the server.
class GameStateManager {
  final List<Player> players;
  int currentRound;

  GameStateManager({required this.players, this.currentRound = 1});

  /// Creates the default game state with 5 players.
  factory GameStateManager.defaultState() => GameStateManager(
        players: [
          Player(id: '1', name: 'Player 1'),
          Player(id: '2', name: 'Player 2'),
          Player(id: '3', name: 'Player 3'),
          Player(id: '4', name: 'Player 4'),
          Player(id: '5', name: 'Player 5'),
        ],
      );

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'currentRound': currentRound,
      };

  String toJsonString() => jsonEncode(toJson());

  /// Finds a player by their ID. Returns null if not found.
  Player? findPlayer(String id) {
    for (final player in players) {
      if (player.id == id) return player;
    }
    return null;
  }

  /// Updates a player's details.
  bool updatePlayer(String id, {String? name, String? photoUrl, int? points}) {
    final player = findPlayer(id);
    if (player == null) return false;
    if (name != null) player.name = name;
    if (photoUrl != null) player.photoUrl = photoUrl;
    if (points != null) player.points = points;
    return true;
  }

  /// Resets all scores to 0 and round to 1.
  void resetAll() {
    for (final player in players) {
      player.points = 0;
    }
    currentRound = 1;
  }
}
