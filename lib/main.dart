import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/admin_screen.dart';
import 'screens/scoreboard_screen.dart';
import 'services/websocket_service.dart';

void main() {
  runApp(const TaskmasterApp());
}

class TaskmasterApp extends StatefulWidget {
  const TaskmasterApp({super.key});

  @override
  State<TaskmasterApp> createState() => _TaskmasterAppState();
}

class _TaskmasterAppState extends State<TaskmasterApp> {
  late final WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    // Connect to the WebSocket server on the same host that served this page.
    final uri = Uri.base;
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final wsUrl = '$scheme://${uri.host}:${uri.port}/ws';
    _webSocketService.connect(wsUrl);
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WebSocketService>.value(
      value: _webSocketService,
      child: MaterialApp(
        title: 'Taskmaster Scoreboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFE6B800),
          scaffoldBackgroundColor: const Color(0xFF0F3460),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE6B800),
            secondary: Color(0xFFE6B800),
            surface: Color(0xFF16213E),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const ScoreboardScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}
