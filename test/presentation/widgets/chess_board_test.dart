import 'package:chess_core_game/src/domain/chess_game_controller.dart';
import 'package:chess_core_game/src/presentation/widgets/chess_board.dart';
import 'package:chess_core_game/src/presentation/widgets/chess_square.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChessBoard renders 64 squares', (WidgetTester tester) async {
    final controller = ChessGameController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChessBoard(controller: controller),
        ),
      ),
    );

    expect(find.byType(ChessSquare), findsNWidgets(64));
  });

  testWidgets('Selecting a square highlights it', (WidgetTester tester) async {
    final controller = ChessGameController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChessBoard(controller: controller),
        ),
      ),
    );

    // Tap a square (e.g., e2)
    // Row 6, Col 4 is index 6 * 8 + 4 = 52
    await tester.tap(find.byType(ChessSquare).at(52));
    await tester.pump();

    // The square should be selected
    final square = tester.widget<ChessSquare>(find.byType(ChessSquare).at(52));
    expect(square.isSelected, isTrue);
  });
}
