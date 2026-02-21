import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess/chess.dart' as chess_lib;

/// A widget that renders a chess piece using SVG.
class ChessPiece extends StatelessWidget {
  /// The type of the piece (P, N, B, R, Q, K).
  final chess_lib.PieceType type;

  /// The color of the piece (WHITE or BLACK).
  final chess_lib.Color color;

  /// The size of the piece.
  final double? size;

  const ChessPiece({
    super.key,
    required this.type,
    required this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorPrefix = color == chess_lib.Color.WHITE ? 'w' : 'b';
    final typeStr = type.toString().toUpperCase();
    final assetPath = 'assets/images/pieces/$colorPrefix$typeStr.svg';

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      // If we are in a package, we might need to specify the package name.
      // For now, assuming it's in the main project.
    );
  }
}
