import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:taskmaster_server/game_state_manager.dart';

/// Default admin password. Override with the --password flag or
/// ADMIN_PASSWORD environment variable.
const _defaultAdminPassword = 'taskmaster';

/// All active WebSocket connections.
final _connections = <WebSocketChannel>[];

/// Connections that have been authenticated as admin.
final _adminConnections = <WebSocketChannel>{};

/// The current game state.
late final GameStateManager _gameState;

/// The admin password for this session.
late final String _adminPassword;

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080', help: 'Port to listen on.')
    ..addOption('password', defaultsTo: '', help: 'Admin password.')
    ..addOption('web-dir',
        defaultsTo: '../build/web',
        help: 'Path to the built Flutter web app directory.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help.');

  final results = parser.parse(args);

  if (results.flag('help')) {
    print('Taskmaster Scoreboard Server\n');
    print(parser.usage);
    exit(0);
  }

  final port = int.parse(results.option('port')!);
  _adminPassword = results.option('password')!.isNotEmpty
      ? results.option('password')!
      : Platform.environment['ADMIN_PASSWORD'] ?? _defaultAdminPassword;
  final webDir = results.option('web-dir')!;

  // Initialize game state
  _gameState = GameStateManager.defaultState();

  // Create the WebSocket handler
  final wsHandler = webSocketHandler((WebSocketChannel ws) {
    _connections.add(ws);

    // Send current state to the new connection
    ws.sink.add(jsonEncode({
      'type': 'state_update',
      'data': _gameState.toJson(),
    }));

    ws.stream.listen(
      (message) => _handleMessage(ws, message as String),
      onDone: () {
        _connections.remove(ws);
        _adminConnections.remove(ws);
      },
      onError: (error) {
        print('WebSocket error: $error');
        _connections.remove(ws);
        _adminConnections.remove(ws);
      },
    );
  });

  // Build the request handler
  Handler handler;
  final webDirPath = Directory(webDir);
  if (webDirPath.existsSync()) {
    final staticHandler = createStaticHandler(
      webDir,
      defaultDocument: 'index.html',
    );
    handler = (Request request) {
      if (request.url.path == 'ws') {
        return wsHandler(request);
      }
      return staticHandler(request);
    };
  } else {
    print('Warning: Web directory "$webDir" not found.');
    print('The server will only handle WebSocket connections.');
    print('Build the Flutter web app with: flutter build web');
    handler = (Request request) {
      if (request.url.path == 'ws') {
        return wsHandler(request);
      }
      return Response.notFound(
          'Web app not built. Run "flutter build web" first.');
    };
  }

  // Add logging middleware
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(handler);

  final server = await shelf_io.serve(pipeline, InternetAddress.anyIPv4, port);
  print('');
  print('╔══════════════════════════════════════════════╗');
  print('║       Taskmaster Scoreboard Server           ║');
  print('╠══════════════════════════════════════════════╣');
  print('║  Server running on:                          ║');
  print('║  http://localhost:${server.port.toString().padRight(28)}║');
  print('║                                              ║');
  print('║  Display view: http://localhost:${server.port.toString().padRight(14)}║');
  print('║  Admin panel:  http://localhost:${server.port}/#/admin    ║');
  print('║                                              ║');
  print('║  Admin password: ${_adminPassword.padRight(28)}║');
  print('╚══════════════════════════════════════════════╝');
  print('');
}

/// Handles incoming WebSocket messages.
void _handleMessage(WebSocketChannel ws, String message) {
  try {
    final data = jsonDecode(message) as Map<String, dynamic>;
    final type = data['type'] as String;

    switch (type) {
      case 'auth':
        _handleAuth(ws, data);
        break;
      case 'update_scores':
        _handleUpdateScores(ws, data);
        break;
      case 'update_player':
        _handleUpdatePlayer(ws, data);
        break;
      case 'set_round':
        _handleSetRound(ws, data);
        break;
      case 'reset_scores':
        _handleResetScores(ws);
        break;
      default:
        _sendError(ws, 'Unknown message type: $type');
    }
  } catch (e) {
    print('Error handling message: $e');
    _sendError(ws, 'Invalid message format');
  }
}

void _handleAuth(WebSocketChannel ws, Map<String, dynamic> data) {
  final password = data['password'] as String;
  final success = password == _adminPassword;
  if (success) {
    _adminConnections.add(ws);
  }
  ws.sink.add(jsonEncode({
    'type': 'auth_response',
    'success': success,
  }));
}

void _handleUpdateScores(WebSocketChannel ws, Map<String, dynamic> data) {
  if (!_adminConnections.contains(ws)) {
    _sendError(ws, 'Not authenticated');
    return;
  }
  final players = data['players'] as List<dynamic>;
  for (final update in players) {
    final map = update as Map<String, dynamic>;
    final id = map['id'] as String;
    final points = map['points'] as int;
    _gameState.updatePlayer(id, points: points);
  }
  _broadcastState();
}

void _handleUpdatePlayer(WebSocketChannel ws, Map<String, dynamic> data) {
  if (!_adminConnections.contains(ws)) {
    _sendError(ws, 'Not authenticated');
    return;
  }
  final id = data['id'] as String;
  _gameState.updatePlayer(
    id,
    name: data['name'] as String?,
    photoUrl: data['photoUrl'] as String?,
    points: data['points'] as int?,
  );
  _broadcastState();
}

void _handleSetRound(WebSocketChannel ws, Map<String, dynamic> data) {
  if (!_adminConnections.contains(ws)) {
    _sendError(ws, 'Not authenticated');
    return;
  }
  _gameState.currentRound = data['round'] as int;
  _broadcastState();
}

void _handleResetScores(WebSocketChannel ws) {
  if (!_adminConnections.contains(ws)) {
    _sendError(ws, 'Not authenticated');
    return;
  }
  _gameState.resetAll();
  _broadcastState();
}

/// Broadcasts the current game state to all connected clients.
void _broadcastState() {
  final message = jsonEncode({
    'type': 'state_update',
    'data': _gameState.toJson(),
  });
  // Iterate over a copy to avoid concurrent modification
  for (final connection in List.of(_connections)) {
    try {
      connection.sink.add(message);
    } catch (e) {
      print('Error broadcasting to connection: $e');
      _connections.remove(connection);
      _adminConnections.remove(connection);
    }
  }
}

void _sendError(WebSocketChannel ws, String message) {
  ws.sink.add(jsonEncode({
    'type': 'error',
    'message': message,
  }));
}
