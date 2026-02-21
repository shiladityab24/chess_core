# Chess Core Game

A full-featured, beautiful, and responsive chess application built with Flutter.

## Features

- **Complete Chess Logic**: Powered by a robust engine (based on `chess.js`) with full move validation, check/checkmate detection, and draw rules.
- **Modern UI**: Built with Material 3 principles, featuring custom-rendered SVG pieces and a clean, adaptive layout.
- **Interactive Gameplay**:
  - **Tap-to-Move**: Intuitive interaction for selecting pieces and seeing legal moves.
  - **Move Highlighting**: Clear indicators for selected pieces, valid destinations, and the last move made.
  - **Flip Board**: Support for playing from both White and Black perspectives.
- **Game Management**:
  - **Undo/Reset**: Easily correct mistakes or start fresh.
  - **Move History**: A real-time log of moves in Standard Algebraic Notation (SAN).
  - **Game-Over Detection**: Automatic detection and notification of Checkmate and Draw states.
- **Responsive Design**: Works seamlessly on mobile, tablet, and desktop screens.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Dart SDK

### Installation

1.  Add the dependencies to your `pubspec.yaml`:
    ```yaml
    dependencies:
      chess: ^0.8.1
      flutter_svg: ^2.0.10+1
    ```

2.  Ensure you have the chess piece assets in your `assets/images/pieces/` directory.

### Usage

```dart
import 'package:chess_core_game/src/domain/chess_game_controller.dart';
import 'package:chess_core_game/src/presentation/widgets/chess_board.dart';

// ... inside your Widget build method
final controller = ChessGameController();

ChessBoard(
  controller: controller,
  flipBoard: false, // Set to true to see from Black's perspective
)
```

## Project Structure

- `lib/src/domain/`: Core game logic and state management (`ChessGameController`).
- `lib/src/presentation/widgets/`: UI components like `ChessBoard`, `ChessSquare`, and `ChessPiece`.
- `assets/images/pieces/`: SVG assets for all chess pieces.

## License

This project is licensed under the MIT License.
