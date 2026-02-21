import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/foundation.dart';
import 'chess_ai.dart';

enum GameMode { playerVsPlayer, playerVsComputer }

/// Controller for managing chess game state and logic.
class ChessGameController extends ChangeNotifier {
  /// Internal chess game engine.
  final chess_lib.Chess _game;

  GameMode _gameMode = GameMode.playerVsPlayer;
  chess_lib.Color _playerColor = chess_lib.Color.WHITE;
  bool _isAiThinking = false;

  /// Creates a new [ChessGameController] with an optional starting [fen].
  ChessGameController({String? fen})
      : _game = fen != null ? chess_lib.Chess.fromFEN(fen) : chess_lib.Chess();

  /// Current FEN string representing the board state.
  String get fen => _game.generate_fen();

  /// Whether it is currently white's turn.
  bool get isWhiteTurn => _game.turn == chess_lib.Color.WHITE;

  /// List of moves played in the game in SAN format.
  List<String> get history => _game.getHistory().cast<String>();

  /// Whether the current position is in check.
  bool get isCheck => _game.in_check;

  /// Whether the game has ended in checkmate.
  bool get isCheckmate => _game.in_checkmate;

  /// Whether the game has ended in a draw.
  bool get isDraw => _game.in_draw;

  /// Whether the game is over.
  bool get isGameOver => _game.game_over;

  /// Current game mode.
  GameMode get gameMode => _gameMode;

  /// The color the human player is playing as.
  chess_lib.Color get playerColor => _playerColor;

  /// Whether the AI is currently calculating a move.
  bool get isAiThinking => _isAiThinking;

  /// Sets the game mode and resets the game if it changed.
  void setGameMode(GameMode mode) {
    if (_gameMode != mode) {
      _gameMode = mode;
      reset();
    }
  }

  /// Sets the player's color and resets the game.
  void setPlayerColor(chess_lib.Color color) {
    if (_playerColor != color) {
      _playerColor = color;
      reset();
    }
  }

  /// Returns the piece at a given square (e.g., 'e2', 'a1').
  chess_lib.Piece? getPieceAt(String square) => _game.get(square);

  /// Returns a list of legal moves for the current turn.
  List<chess_lib.Move> getLegalMoves({String? square}) {
    return _game.generate_moves({'square': square}).cast<chess_lib.Move>();
  }

  /// Attempts to make a move using a SAN or coordinate.
  /// Returns true if the move was successful.
  bool makeMove(dynamic move) {
    if (_isAiThinking || isGameOver) return false;

    // Check if it's the player's turn in PvC mode
    if (_gameMode == GameMode.playerVsComputer && _game.turn != _playerColor) {
      return false;
    }

    if (move is String) {
      final cleanInput = move.replaceAll(RegExp(r'[+#?!=]+$'), '');
      final legalMoves = _game.generate_moves();
      for (final m in legalMoves) {
        final san = _game.move_to_san(m);
        if (san.replaceAll(RegExp(r'[+#?!=]+$'), '') == cleanInput) {
          final success = _game.move(san);
          if (success) {
            _handleMoveSuccess();
            return true;
          }
        }
      }
    }

    final success = _game.move(move);
    if (success) {
      _handleMoveSuccess();
    }
    return success;
  }

  void _handleMoveSuccess() {
    notifyListeners();
    if (_gameMode == GameMode.playerVsComputer && !isGameOver && _game.turn != _playerColor) {
      _makeAiMove();
    }
  }

  Future<void> _makeAiMove() async {
    _isAiThinking = true;
    notifyListeners();

    // Small delay for UI to update and feel more natural
    await Future.delayed(const Duration(milliseconds: 500));

    // Calculate best move (depth 3 for decent level)
    final bestMove = ChessAI.getBestMove(_game, 3);
    if (bestMove != null) {
      _game.move(bestMove);
    }

    _isAiThinking = false;
    notifyListeners();
  }

  /// Undoes the last move (two moves in PvC mode).
  void undo() {
    if (_isAiThinking) return;
    _game.undo();
    if (_gameMode == GameMode.playerVsComputer && _game.turn != _playerColor) {
      _game.undo();
    }
    notifyListeners();
  }

  /// Resets the game to the initial position.
  void reset() {
    _game.reset();
    _isAiThinking = false;
    notifyListeners();
    
    // If computer is White, it makes the first move
    if (_gameMode == GameMode.playerVsComputer && _playerColor == chess_lib.Color.BLACK) {
      _makeAiMove();
    }
  }

  /// Loads a game from a PGN string.
  bool loadPgn(String pgn) {
    final success = _game.load_pgn(pgn);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  /// Exports the current game history to a PGN string.
  String exportPgn() => _game.pgn();
}
