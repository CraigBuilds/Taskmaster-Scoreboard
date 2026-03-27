import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaster_scoreboard/models/game_state.dart';

void main() {
  group('Player', () {
    test('creates player with default values', () {
      final player = Player(id: '1', name: 'Test');
      expect(player.id, '1');
      expect(player.name, 'Test');
      expect(player.photoUrl, '');
      expect(player.points, 0);
    });

    test('serializes to JSON', () {
      final player =
          Player(id: '1', name: 'Alice', photoUrl: 'http://example.com/photo.png', points: 5);
      final json = player.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Alice');
      expect(json['photoUrl'], 'http://example.com/photo.png');
      expect(json['points'], 5);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': '2',
        'name': 'Bob',
        'photoUrl': '',
        'points': 10,
      };
      final player = Player.fromJson(json);
      expect(player.id, '2');
      expect(player.name, 'Bob');
      expect(player.photoUrl, '');
      expect(player.points, 10);
    });

    test('copyWith creates a new player with updated fields', () {
      final player = Player(id: '1', name: 'Alice', points: 5);
      final updated = player.copyWith(name: 'Alice Updated', points: 10);
      expect(updated.id, '1');
      expect(updated.name, 'Alice Updated');
      expect(updated.points, 10);
      // Original unchanged
      expect(player.name, 'Alice');
      expect(player.points, 5);
    });
  });

  group('GameState', () {
    test('creates default state with 5 players', () {
      final state = GameState.defaultState();
      expect(state.players.length, 5);
      expect(state.currentRound, 1);
    });

    test('sortedPlayers returns players ordered by points descending', () {
      final state = GameState(
        players: [
          Player(id: '1', name: 'Alice', points: 3),
          Player(id: '2', name: 'Bob', points: 7),
          Player(id: '3', name: 'Charlie', points: 1),
          Player(id: '4', name: 'Dana', points: 10),
          Player(id: '5', name: 'Evan', points: 5),
        ],
      );
      final sorted = state.sortedPlayers;
      expect(sorted[0].name, 'Dana');
      expect(sorted[1].name, 'Bob');
      expect(sorted[2].name, 'Evan');
      expect(sorted[3].name, 'Alice');
      expect(sorted[4].name, 'Charlie');
    });

    test('serializes and deserializes correctly', () {
      final state = GameState(
        players: [
          Player(id: '1', name: 'Alice', points: 3),
          Player(id: '2', name: 'Bob', points: 7),
        ],
        currentRound: 3,
      );
      final json = state.toJson();
      final restored = GameState.fromJson(json);
      expect(restored.players.length, 2);
      expect(restored.players[0].name, 'Alice');
      expect(restored.players[0].points, 3);
      expect(restored.players[1].name, 'Bob');
      expect(restored.players[1].points, 7);
      expect(restored.currentRound, 3);
    });

    test('toJsonString and fromJsonString roundtrip', () {
      final state = GameState(
        players: [
          Player(id: '1', name: 'Alice', points: 5),
        ],
        currentRound: 2,
      );
      final jsonStr = state.toJsonString();
      final restored = GameState.fromJsonString(jsonStr);
      expect(restored.players.length, 1);
      expect(restored.players[0].name, 'Alice');
      expect(restored.currentRound, 2);
    });
  });
}
