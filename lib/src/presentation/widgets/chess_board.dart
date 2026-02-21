import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../../domain/chess_game_controller.dart';
import 'chess_square.dart';
import 'chess_piece.dart';

/// A chessboard widget that renders the board and pieces.
class ChessBoard extends StatefulWidget {
  /// The game controller.
  final ChessGameController controller;

  /// The size of the board.
  final double? size;

  /// Whether the board is flipped (Black at bottom).
  final bool flipBoard;

  /// Colors for the squares.
  final Color lightColor;
  final Color darkColor;

  const ChessBoard({
    super.key,
    required this.controller,
    this.size,
    this.flipBoard = false,
    this.lightColor = const Color(0xFFF0D9B5),
    this.darkColor = const Color(0xFFB58863),
  });

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  /// The currently selected square (in algebraic notation, e.g., 'e2').
  String? _selectedSquare;

  /// List of legal move destinations for the selected piece.
  List<String> _legalMoves = [];

  void _handleSquareTap(String square) {
    setState(() {
      // If we tapped the same square, deselect it.
      if (_selectedSquare == square) {
        _selectedSquare = null;
        _legalMoves = [];
        return;
      }

      // If we tapped a legal move destination, make the move.
      if (_legalMoves.contains(square)) {
        widget.controller.makeMove({
          'from': _selectedSquare,
          'to': square,
        });
        _selectedSquare = null;
        _legalMoves = [];
        return;
      }

      // Check if there's a piece belonging to the current player on the tapped square.
      final piece = widget.controller.getPieceAt(square);
      if (piece != null &&
          ((piece.color == chess_lib.Color.WHITE &&
                  widget.controller.isWhiteTurn) ||
              (piece.color == chess_lib.Color.BLACK &&
                  !widget.controller.isWhiteTurn))) {
        _selectedSquare = square;
        // Get legal moves for the selected piece
        _legalMoves = widget.controller
            .getLegalMoves(square: square)
            .map((m) => m.toAlgebraic)
            .toList();
      } else {
        _selectedSquare = null;
        _legalMoves = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                // Adjust index based on flipBoard
                final actualIndex = widget.flipBoard ? 63 - index : index;

                final row = actualIndex ~/ 8;
                final col = actualIndex % 8;
                final square = String.fromCharCode('a'.codeUnitAt(0) + col) +
                    String.fromCharCode('8'.codeUnitAt(0) - row);

                final isLight = (row + col) % 2 == 0;
                final color = isLight ? widget.lightColor : widget.darkColor;

                final piece = widget.controller.getPieceAt(square);

                return ChessSquare(
                  color: color,
                  isSelected: _selectedSquare == square,
                  isHighlight: _legalMoves.contains(square),
                  onTap: () => _handleSquareTap(square),
                  child: piece != null
                      ? ChessPiece(
                          type: piece.type,
                          color: piece.color,
                        )
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
