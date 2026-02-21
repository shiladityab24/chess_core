import 'dart:math';
import 'package:chess/chess.dart' as chess_lib;

/// A simple chess AI using Minimax with Alpha-Beta pruning.
class ChessAI {
  /// Material values for pieces.
  static final Map<chess_lib.PieceType, int> _pieceValues = {
    chess_lib.PieceType.PAWN: 100,
    chess_lib.PieceType.KNIGHT: 320,
    chess_lib.PieceType.BISHOP: 330,
    chess_lib.PieceType.ROOK: 500,
    chess_lib.PieceType.QUEEN: 900,
    chess_lib.PieceType.KING: 20000,
  };

  /// Simplified Piece-Square Tables (PST).
  static final Map<chess_lib.PieceType, List<int>> _pst = {
    chess_lib.PieceType.PAWN: [
      0,  0,  0,  0,  0,  0,  0,  0,
      50, 50, 50, 50, 50, 50, 50, 50,
      10, 10, 20, 30, 30, 20, 10, 10,
      5,  5, 10, 25, 25, 10,  5,  5,
      0,  0,  0, 20, 20,  0,  0,  0,
      5, -5,-10,  0,  0,-10, -5,  5,
      5, 10, 10,-20,-20, 10, 10,  5,
      0,  0,  0,  0,  0,  0,  0,  0
    ],
    chess_lib.PieceType.KNIGHT: [
      -50,-40,-30,-30,-30,-30,-40,-50,
      -40,-20,  0,  0,  0,  0,-20,-40,
      -30,  0, 10, 15, 15, 10,  0,-30,
      -30,  5, 15, 20, 20, 15,  5,-30,
      -30,  0, 15, 20, 20, 15,  0,-30,
      -30,  5, 10, 15, 15, 10,  5,-30,
      -40,-20,  0,  5,  5,  0,-20,-40,
      -50,-40,-30,-30,-30,-30,-40,-50
    ],
    chess_lib.PieceType.BISHOP: [
      -20,-10,-10,-10,-10,-10,-10,-20,
      -10,  0,  0,  0,  0,  0,  0,-10,
      -10,  0,  5, 10, 10,  5,  0,-10,
      -10,  5,  5, 10, 10,  5,  5,-10,
      -10,  0, 10, 10, 10, 10,  0,-10,
      -10, 10, 10, 10, 10, 10, 10,-10,
      -10,  5,  0,  0,  0,  0,  5,-10,
      -20,-10,-10,-10,-10,-10,-10,-20
    ],
    chess_lib.PieceType.ROOK: [
      0,  0,  0,  0,  0,  0,  0,  0,
      5, 10, 10, 10, 10, 10, 10,  5,
     -5,  0,  0,  0,  0,  0,  0, -5,
     -5,  0,  0,  0,  0,  0,  0, -5,
     -5,  0,  0,  0,  0,  0,  0, -5,
     -5,  0,  0,  0,  0,  0,  0, -5,
     -5,  0,  0,  0,  0,  0,  0, -5,
      0,  0,  0,  5,  5,  0,  0,  0
    ],
    chess_lib.PieceType.QUEEN: [
      -20,-10,-10, -5, -5,-10,-10,-20,
      -10,  0,  0,  0,  0,  0,  0,-10,
      -10,  0,  5,  5,  5,  5,  0,-10,
       -5,  0,  5,  5,  5,  5,  0, -5,
        0,  0,  5,  5,  5,  5,  0, -5,
      -10,  5,  5,  5,  5,  5,  0,-10,
      -10,  0,  5,  0,  0,  0,  0,-10,
      -20,-10,-10, -5, -5,-10,-10,-20
    ],
    chess_lib.PieceType.KING: [
      -30,-40,-40,-50,-50,-40,-40,-30,
      -30,-40,-40,-50,-50,-40,-40,-30,
      -30,-40,-40,-50,-50,-40,-40,-30,
      -30,-40,-40,-50,-50,-40,-40,-30,
      -20,-30,-30,-40,-40,-30,-30,-20,
      -10,-20,-20,-20,-20,-20,-20,-10,
       20, 20,  0,  0,  0,  0, 20, 20,
       20, 30, 10,  0,  0, 10, 30, 20
    ],
  };

  /// Computes the best move for the current position.
  static chess_lib.Move? getBestMove(chess_lib.Chess game, int depth) {
    final moves = game.generate_moves();
    if (moves.isEmpty) return null;

    // Shuffle moves to add some variety for equal evaluations
    moves.shuffle();

    chess_lib.Move? bestMove;
    int bestValue = game.turn == chess_lib.Color.WHITE ? -1000000 : 1000000;

    for (final move in moves) {
      game.make_move(move);
      final boardValue = _minimax(game, depth - 1, -1000000, 1000000, game.turn == chess_lib.Color.WHITE);
      game.undo_move();

      if (game.turn == chess_lib.Color.WHITE) {
        if (boardValue > bestValue) {
          bestValue = boardValue;
          bestMove = move;
        }
      } else {
        if (boardValue < bestValue) {
          bestValue = boardValue;
          bestMove = move;
        }
      }
    }

    return bestMove;
  }

  static int _minimax(chess_lib.Chess game, int depth, int alpha, int beta, bool isMaximizingPlayer) {
    if (depth == 0) {
      return _evaluateBoard(game);
    }

    final moves = game.generate_moves();
    if (moves.isEmpty) {
      if (game.in_check) {
        return isMaximizingPlayer ? -999999 : 999999; // Checkmate
      }
      return 0; // Draw
    }

    if (isMaximizingPlayer) {
      int bestValue = -1000000;
      for (final move in moves) {
        game.make_move(move);
        bestValue = max(bestValue, _minimax(game, depth - 1, alpha, beta, !isMaximizingPlayer));
        game.undo_move();
        alpha = max(alpha, bestValue);
        if (beta <= alpha) break;
      }
      return bestValue;
    } else {
      int bestValue = 1000000;
      for (final move in moves) {
        game.make_move(move);
        bestValue = min(bestValue, _minimax(game, depth - 1, alpha, beta, !isMaximizingPlayer));
        game.undo_move();
        beta = min(beta, bestValue);
        if (beta <= alpha) break;
      }
      return bestValue;
    }
  }

  static int _evaluateBoard(chess_lib.Chess game) {
    int totalEvaluation = 0;
    for (int i = 0; i < 128; i++) {
      if ((i & 0x88) != 0) continue;
      final piece = game.board[i];
      if (piece != null) {
        totalEvaluation += _getPieceValue(piece, i);
      }
    }
    return totalEvaluation;
  }

  static int _getPieceValue(chess_lib.Piece piece, int square) {
    final sign = piece.color == chess_lib.Color.WHITE ? 1 : -1;
    int val = _pieceValues[piece.type] ?? 0;

    // PST lookup
    final pstTable = _pst[piece.type];
    if (pstTable != null) {
      // Map 0x88 square to 0-63
      final row = square >> 4;
      final col = square & 7;
      // Flip PST for black to treat board as if viewed from their side
      final index = piece.color == chess_lib.Color.WHITE ? (row * 8 + col) : ((7 - row) * 8 + col);
      val += pstTable[index];
    }

    return sign * val;
  }
}
