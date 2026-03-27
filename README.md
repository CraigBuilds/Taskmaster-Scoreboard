# Taskmaster Scoreboard

[![CI](https://github.com/CraigBuilds/Taskmaster-Scoreboard/actions/workflows/ci.yml/badge.svg)](https://github.com/CraigBuilds/Taskmaster-Scoreboard/actions/workflows/ci.yml)
[![Deploy to GitHub Pages](https://github.com/CraigBuilds/Taskmaster-Scoreboard/actions/workflows/deploy.yml/badge.svg)](https://github.com/CraigBuilds/Taskmaster-Scoreboard/actions/workflows/deploy.yml)

**🎬 Live demo: [https://craigbuilds.github.io/Taskmaster-Scoreboard/](https://craigbuilds.github.io/Taskmaster-Scoreboard/)**

A live Taskmaster scoreboard web app built with Flutter. It displays the scores of 5 players (each with an avatar), ordered by points. Multiple web browsers can connect and view the live scoreboard, and an admin panel allows the Taskmaster's assistant to edit scores and trigger real-time updates.

## Features

- **Live Scoreboard Display** — Shows all 5 players ranked by score with avatars and a gold/dark Taskmaster theme
- **Real-time Updates** — All connected browsers update instantly via WebSocket when scores change
- **Admin Panel** — Password-protected admin view to edit player names, scores, and control the round
- **Multi-client Support** — Multiple browsers can view the scoreboard simultaneously
- **Round Tracking** — Track the current round number

## Architecture

The app consists of two parts:

1. **Flutter Web Client** (`lib/`) — The frontend UI with two views:
   - Scoreboard display (route: `/`) — For showing on the big screen
   - Admin panel (route: `/#/admin`) — For the Taskmaster's assistant

2. **Dart Server** (`server/`) — Backend that:
   - Serves the built Flutter web app as static files
   - Manages game state in memory
   - Provides WebSocket connections for real-time updates
   - Handles admin authentication and score updates

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 or later)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)

## Getting Started

### 1. Build the Flutter web app

```bash
flutter pub get
flutter build web
```

### 2. Start the server

```bash
cd server
dart pub get
dart run bin/server.dart
```

The server will start on `http://localhost:8080` by default.

### 3. Open in your browser

- **Scoreboard display:** `http://localhost:8080`
- **Admin panel:** `http://localhost:8080/#/admin`

The default admin password is `taskmaster`. You can change it with:

```bash
dart run bin/server.dart --password your_secret_password
```

Or set the `ADMIN_PASSWORD` environment variable.

## Server Options

```
--port, -p     Port to listen on (default: 8080)
--password     Admin password (default: taskmaster)
--web-dir      Path to the built Flutter web app (default: ../build/web)
-h, --help     Show help
```

## Development

To run the Flutter web app in development mode:

```bash
flutter run -d chrome
```

Note: During development, the Flutter dev server runs on a different port. You'll need to also run the Dart server separately for WebSocket functionality.

## Project Structure

```
├── lib/
│   ├── main.dart                  # App entry point and routing
│   ├── models/
│   │   └── game_state.dart        # Player and GameState data models
│   ├── screens/
│   │   ├── scoreboard_screen.dart # Main scoreboard display view
│   │   └── admin_screen.dart      # Admin panel with score editing
│   ├── services/
│   │   └── websocket_service.dart # WebSocket connection management
│   └── widgets/
│       ├── player_card.dart       # Player display card for scoreboard
│       └── player_score_editor.dart # Score editing widget for admin
├── server/
│   ├── bin/
│   │   └── server.dart            # Server entry point
│   ├── lib/
│   │   └── game_state_manager.dart # Server-side game state
│   └── pubspec.yaml
├── test/
│   └── game_state_test.dart       # Unit tests for data models
├── web/
│   ├── index.html                 # Flutter web entry point
│   └── manifest.json              # PWA manifest
├── pubspec.yaml
└── README.md
```
