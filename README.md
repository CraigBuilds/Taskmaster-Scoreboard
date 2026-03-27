# Taskmaster Scoreboard

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

## Sharing on the same Wi-Fi

No code changes are needed. Once the server is running on your laptop, anyone on the **same Wi-Fi network** can connect from their phone or browser.

### 1. Run the app on your laptop

Follow the [Getting Started](#getting-started) steps above. The server listens on port **8080** by default.

### 2. Find your laptop's LAN IP address

| OS | Command | Look for |
|----|---------|----------|
| Windows | `ipconfig` | **IPv4 Address** under your Wi-Fi adapter |
| macOS | `ifconfig \| grep inet` | `inet 192.168.x.x` (not `127.0.0.1`) |
| Linux | `ip a` | `inet 192.168.x.x` or `inet 10.x.x.x` |

Example result: `192.168.1.50`

### 3. Have everyone open the app on their phone or browser

Replace `192.168.1.50` with your actual LAN IP:

- **Scoreboard:** `http://192.168.1.50:8080`
- **Admin panel:** `http://192.168.1.50:8080/#/admin`

Because the page is served from your laptop, the Flutter app automatically connects its WebSocket back to `ws://192.168.1.50:8080/ws` — no extra configuration required.

> **Note:** `http://localhost:8080` only works on your own machine. Remote devices must use the host's LAN IP address.

### Troubleshooting

- **Can't connect at all** — Make sure the phone is on the **same Wi-Fi network** as your laptop (not cellular, not a guest network). Many guest/public Wi-Fi networks isolate devices from each other.
- **Connection refused or timed out** — Your laptop **firewall** may be blocking inbound connections on port 8080. Allow the port (or the Dart executable) through your firewall:
  - *Windows:* Windows Defender Firewall → Advanced Settings → add an inbound rule for TCP port 8080.
  - *macOS:* System Settings → Network → Firewall → allow incoming connections for Dart.
  - *Linux:* `sudo ufw allow 8080/tcp` (if using UFW).
- **Port 8080 is already in use** — Start the server on a different port and use that port in the URL:
  ```bash
  dart run bin/server.dart --port 8081
  ```
  Then connect to `http://192.168.1.50:8081`.
- **Scores don't update in real time** — Check that the browser's address bar shows the LAN IP (not `localhost`). If it shows `localhost`, the WebSocket will also try to connect to `localhost` on the remote device, which will fail.

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
