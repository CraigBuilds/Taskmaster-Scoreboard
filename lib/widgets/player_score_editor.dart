import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_state.dart';

/// A widget that allows an admin to edit a player's name and score.
class PlayerScoreEditor extends StatefulWidget {
  final Player player;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<String> onNameChanged;

  const PlayerScoreEditor({
    super.key,
    required this.player,
    required this.onPointsChanged,
    required this.onNameChanged,
  });

  @override
  State<PlayerScoreEditor> createState() => _PlayerScoreEditorState();
}

class _PlayerScoreEditorState extends State<PlayerScoreEditor> {
  late TextEditingController _nameController;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _pointsController =
        TextEditingController(text: widget.player.points.toString());
  }

  @override
  void didUpdateWidget(PlayerScoreEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player.name != widget.player.name) {
      _nameController.text = widget.player.name;
    }
    if (oldWidget.player.points != widget.player.points) {
      _pointsController.text = widget.player.points.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  /// Returns a background color for the player's avatar based on their ID.
  Color _avatarColor() {
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFF8E24AA),
      const Color(0xFFFB8C00),
    ];
    final index = int.tryParse(widget.player.id) ?? 0;
    return colors[(index - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF16213E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Player avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _avatarColor(),
              child: Text(
                widget.player.name.isNotEmpty
                    ? widget.player.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name field
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE6B800)),
                  ),
                ),
                onChanged: widget.onNameChanged,
              ),
            ),
            const SizedBox(width: 16),
            // Points field
            Expanded(
              flex: 2,
              child: TextField(
                controller: _pointsController,
                style: const TextStyle(
                  color: Color(0xFFE6B800),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Points',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE6B800)),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                onChanged: (value) {
                  final points = int.tryParse(value);
                  if (points != null) {
                    widget.onPointsChanged(points);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Quick adjust buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF43A047)),
                  iconSize: 32,
                  onPressed: () {
                    final current = int.tryParse(_pointsController.text) ?? 0;
                    final newPoints = current + 1;
                    _pointsController.text = newPoints.toString();
                    widget.onPointsChanged(newPoints);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Color(0xFFE53935)),
                  iconSize: 32,
                  onPressed: () {
                    final current = int.tryParse(_pointsController.text) ?? 0;
                    final newPoints = current - 1;
                    _pointsController.text = newPoints.toString();
                    widget.onPointsChanged(newPoints);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
