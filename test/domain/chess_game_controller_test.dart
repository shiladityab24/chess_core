import 'package:chess_core_game/src/domain/chess_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChessGameController', () {
    test('initial state is correct', () {
      final controller = ChessGameController();
      expect(controller.fen,
          contains('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'));
      expect(controller.isWhiteTurn, isTrue);
      expect(controller.isCheck, isFalse);
      expect(controller.isGameOver, isFalse);
    });

    test('makeMove changes state', () {
      final controller = ChessGameController();
      final success = controller.makeMove('e4');
      expect(success, isTrue);
      expect(controller.isWhiteTurn, isFalse);
      expect(
          controller.fen,
          contains(
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1'));
    });

    test('undo reverses move', () {
      final controller = ChessGameController();
      final initialFen = controller.fen;
      controller.makeMove('e4');
      controller.undo();
      expect(controller.fen, equals(initialFen));
      expect(controller.isWhiteTurn, isTrue);
    });

    test('reset clears game', () {
      final controller = ChessGameController();
      final initialFen = controller.fen;
      controller.makeMove('e4');
      controller.reset();
      expect(controller.fen, equals(initialFen));
    });

    test('checkmate detection', () {
      final controller = ChessGameController();
      // Fool's Mate
      controller.makeMove('f3');
      controller.makeMove('e5');
      controller.makeMove('g4');
      controller.makeMove('Qh4');

      expect(controller.isCheck, isTrue);
      expect(controller.isCheckmate, isTrue);
      expect(controller.isGameOver, isTrue);
    });
  });
}
