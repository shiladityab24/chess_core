# GEMINI.md - Chess Core Game

## Overview
`chess_core_game` is a Flutter-based chess application designed to provide a comprehensive, functional, and visually appealing chess experience. It leverages a robust game engine for rule enforcement while offering a modern, responsive UI built with Material 3.

## Purpose
The project serves as a full-featured chess implementation that can be used as a standalone application or a library. It addresses common chess application requirements:
- Reliable move validation (SAN/Coordinate).
- Real-time game state tracking (Check, Mate, Draw).
- High-quality piece rendering using SVG.
- Responsive layout for cross-platform support.

## Core Components

### 1. Domain Layer (`lib/src/domain/`)
- **`ChessGameController`**: The central state manager. It wraps the `chess` package (version 0.8.1), translating its internal state into a Flutter-friendly `ChangeNotifier`. It handles:
  - Applying moves and validating legality.
  - Tracking current turn and board state (FEN).
  - Managing move history (PGN).
  - Undo/Reset operations.

### 2. Presentation Layer (`lib/src/presentation/widgets/`)
- **`ChessBoard`**: A responsive 8x8 grid widget that coordinates the rendering of squares and pieces. It supports flipping the board and handles user interactions.
- **`ChessSquare`**: Represents an individual square on the board, managing its color, highlights (selected, last move, legal move), and tap events.
- **`ChessPiece`**: A widget that dynamically renders pieces using SVG assets from `assets/images/pieces/`.
- **`MoveHistory`**: A scrollable list widget that displays the game's move history in Standard Algebraic Notation (SAN).

### 3. Data & Assets (`assets/images/pieces/`)
- High-quality SVG assets for all pieces:
  - White: `wP`, `wN`, `wB`, `wR`, `wQ`, `wK`.
  - Black: `bP`, `bN`, `bB`, `bR`, `bQ`, `bK`.

## Implementation Details
- **State Management**: Uses `ChangeNotifier` and `ListenableBuilder` for efficient, reactive UI updates.
- **Move Logic**: Move validation is performed using the `chess` package's `generate_moves` method. The `makeMove` method in the controller is enhanced to robustly match SAN inputs even when decorators (+, #) are omitted.
- **Responsiveness**: The `main.dart` entry point uses `LayoutBuilder` to switch between a vertical (Column) layout for narrow screens and a horizontal (Row) layout for wider screens.

## Testing
- **Unit Tests**: `test/domain/chess_game_controller_test.dart` covers initialization, move application, undo/reset, and checkmate detection.
- **Widget Tests**: `test/presentation/widgets/chess_board_test.dart` verifies that the board renders 64 squares and correctly handles square selection.

## Future Enhancements
- Integration with AI engines (e.g., Stockfish) via UCI.
- Online multiplayer support using WebSockets.
- Timers and clocks for blitz/rapid games.
- Sound effects for moves and captures.
