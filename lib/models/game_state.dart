import 'dart:convert';

/// Represents a player/contestant in the Taskmaster game.
class Player {
  final String id;
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

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String? ?? '',
        points: json['points'] as int? ?? 0,
      );

  Player copyWith({String? name, String? photoUrl, int? points}) => Player(
        id: id,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        points: points ?? this.points,
      );
}

/// Represents the full game state broadcast to all clients.
class GameState {
  final List<Player> players;
  int currentRound;

  GameState({
    required this.players,
    this.currentRound = 1,
  });

  /// Returns players sorted by points in descending order.
  List<Player> get sortedPlayers =>
      List<Player>.from(players)..sort((a, b) => b.points.compareTo(a.points));

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'currentRound': currentRound,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        players: (json['players'] as List<dynamic>)
            .map((p) => Player.fromJson(p as Map<String, dynamic>))
            .toList(),
        currentRound: json['currentRound'] as int? ?? 1,
      );

  String toJsonString() => jsonEncode(toJson());

  factory GameState.fromJsonString(String jsonString) =>
      GameState.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  /// Creates the default initial game state with 5 players.
  factory GameState.defaultState() => GameState(
        players: [
          Player(id: '1', name: 'Player 1'),
          Player(id: '2', name: 'Player 2'),
          Player(id: '3', name: 'Player 3'),
          Player(id: '4', name: 'Player 4'),
          Player(id: '5', name: 'Player 5'),
        ],
      );
}
