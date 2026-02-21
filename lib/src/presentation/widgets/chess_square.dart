import 'package:flutter/material.dart';

/// A single square on the chessboard.
class ChessSquare extends StatelessWidget {
  /// The color of the square (light or dark).
  final Color color;

  /// Whether this square is currently selected.
  final bool isSelected;

  /// Whether this square is a valid move destination for the selected piece.
  final bool isHighlight;

  /// Whether this square was part of the last move.
  final bool isLastMove;

  /// The child widget (usually a piece).
  final Widget? child;

  /// Callback when the square is tapped.
  final VoidCallback? onTap;

  const ChessSquare({
    super.key,
    required this.color,
    this.isSelected = false,
    this.isHighlight = false,
    this.isLastMove = false,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        child: Stack(
          children: [
            // Selected Highlight
            if (isSelected)
              Container(
                color: Colors.yellow.withValues(alpha: 0.5),
              ),
            // Last Move Highlight
            if (isLastMove)
              Container(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            // Valid Move Dot
            if (isHighlight)
              Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Piece
            if (child != null) Center(child: child),
          ],
        ),
      ),
    );
  }
}
