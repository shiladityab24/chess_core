import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'src/domain/chess_game_controller.dart';
import 'src/presentation/widgets/chess_board.dart';
import 'src/presentation/widgets/move_history.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const ChessGamePage(),
    );
  }
}

class ChessGamePage extends StatefulWidget {
  const ChessGamePage({super.key});

  @override
  State<ChessGamePage> createState() => _ChessGamePageState();
}

class _ChessGamePageState extends State<ChessGamePage> {
  late final ChessGameController _controller;
  bool _manualFlip = false;

  @override
  void initState() {
    super.initState();
    _controller = ChessGameController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _shouldFlipBoard =>
      _manualFlip || _controller.playerColor == chess_lib.Color.BLACK;

  void _showGameOverDialog() {
    String message = "";
    if (_controller.isCheckmate) {
      message =
          "Checkmate! ${_controller.isWhiteTurn ? "Black" : "White"} wins.";
    } else if (_controller.isDraw) {
      message = "Draw!";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.reset();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isGameOver) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _showGameOverDialog());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chess Master'),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Move History',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset Game',
                onPressed: () => _controller.reset(),
              ),
            ],
          ),
          // Using endDrawer for move history
          endDrawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Game History',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: MoveHistory(history: _controller.history),
                  ),
                ],
              ),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTurnIndicator(),
                    const SizedBox(height: 24),
                    ChessBoard(
                      controller: _controller,
                      flipBoard: _shouldFlipBoard,
                      // Responsive board size
                      size: MediaQuery.of(context).size.width > 600 ? 500 : null,
                    ),
                    const SizedBox(height: 24),
                    _buildControls(),
                    const SizedBox(height: 24),
                    _buildGameSettings(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _controller.isAiThinking
            ? "Computer is thinking..."
            : (_controller.isWhiteTurn ? "White's Turn" : "Black's Turn"),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.undo),
          tooltip: 'Undo',
          onPressed: _controller.history.isEmpty || _controller.isAiThinking
              ? null
              : () => _controller.undo(),
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          icon: const Icon(Icons.flip),
          tooltip: 'Manual Flip',
          onPressed: () => setState(() => _manualFlip = !_manualFlip),
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          icon: const Icon(Icons.settings_backup_restore),
          tooltip: 'Reset',
          onPressed: _controller.isAiThinking ? null : () => _controller.reset(),
        ),
      ],
    );
  }

  Widget _buildGameSettings() {
    return Column(
      children: [
        SegmentedButton<GameMode>(
          segments: const [
            ButtonSegment(
              value: GameMode.playerVsPlayer,
              label: Text('PvP'),
              icon: Icon(Icons.person),
            ),
            ButtonSegment(
              value: GameMode.playerVsComputer,
              label: Text('vs AI'),
              icon: Icon(Icons.computer),
            ),
          ],
          selected: {_controller.gameMode},
          onSelectionChanged: (newSelection) {
            if (!_controller.isAiThinking) {
              _controller.setGameMode(newSelection.first);
            }
          },
        ),
        const SizedBox(height: 12),
        if (_controller.gameMode == GameMode.playerVsComputer)
          SegmentedButton<chess_lib.Color>(
            segments: const [
              ButtonSegment(
                value: chess_lib.Color.WHITE,
                label: Text('Play as White'),
              ),
              ButtonSegment(
                value: chess_lib.Color.BLACK,
                label: Text('Play as Black'),
              ),
            ],
            selected: {_controller.playerColor},
            onSelectionChanged: (newSelection) {
              if (!_controller.isAiThinking) {
                _controller.setPlayerColor(newSelection.first);
              }
            },
          ),
      ],
    );
  }
}
