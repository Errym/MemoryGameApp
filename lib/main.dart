import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MemoryGameApp());

class MemoryGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'CuteFont', fontSize: 20),
        ),
      ),
      home: MemoryGameScreen(),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> with SingleTickerProviderStateMixin {
  final List<String> _emojiList = [
    '🐶', '🐱', '🐭', '🐹', '🦊', '🐻', '🐼', '🐨',
    '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧',
    '🐦', '🐤', '🦄', '🐳', '🐟', '🦋', '🌸', '🌼'
  ];
  List<String> _gameBoard = [];
  List<bool> _revealed = [];
  int _selectedIndex = -1;
  int _score = 0;
  int _level = 1;
  bool _lock = false;
  int _timeLeft = 60; // Initial time for each level
  Timer? _timer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _initializeGame();
  }

  void _initializeGame() {
    int gridSize = _getGridSize(_level);
    List<String> levelEmojis = _emojiList.sublist(0, gridSize ~/ 2);
    List<String> cards = [...levelEmojis, ...levelEmojis];
    cards.shuffle(Random());
    _resetTimer();
    setState(() {
      _gameBoard = cards;
      _revealed = List.filled(cards.length, false);
      _score = 0;
      _selectedIndex = -1;
      _lock = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timeLeft = 60 - (_level - 1) * 5; // Decrease time as levels increase
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _showLoseDialog();
      }
    });
  }

  int _getGridSize(int level) {
    switch (level) {
      case 1:
        return 4; // 2x2
      case 2:
        return 16; // 4x4
      case 3:
        return 36; // 6x6
      case 4:
        return 64; // 8x8
      case 5:
        return 100; // 10x10
      case 6:
        return 144; // 12x12
      case 7:
        return 196; // 14x14
      case 8:
        return 256; // 16x16
      case 9:
        return 324; // 18x18
      case 10:
        return 400; // 20x20
      default:
        return 4; // Default to 2x2
    }
  }

  void _onCardTap(int index) {
    if (_lock || _revealed[index]) return;

    setState(() {
      _revealed[index] = true;
    });

    if (_selectedIndex == -1) {
      _selectedIndex = index;
    } else {
      if (_gameBoard[_selectedIndex] == _gameBoard[index]) {
        _score++;
        _selectedIndex = -1;
        if (_score == _gameBoard.length ~/ 2) {
          _timer?.cancel();
          if (_level < 10) {
            _level++;
            _initializeGame();
          } else {
            _showWinDialog();
          }
        }
      } else {
        _lock = true;
        Timer(Duration(seconds: 1), () {
          setState(() {
            _revealed[_selectedIndex] = false;
            _revealed[index] = false;
            _selectedIndex = -1;
            _lock = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You completed all 10 levels!'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _level = 1;
                _initializeGame();
              });
              Navigator.of(context).pop();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showLoseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time Up!'),
        content: Text('You ran out of time. Try again?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _initializeGame();
              });
              Navigator.of(context).pop();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = sqrt(_gameBoard.length).toInt();
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game - Level $_level', style: TextStyle(fontFamily: 'CuteFont')),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $_score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontFamily: 'CuteFont',
                  ),
                ),
                Text(
                  'Time: $_timeLeft s',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontFamily: 'CuteFont',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              padding: const EdgeInsets.all(16.0),
              itemCount: _gameBoard.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _revealed[index] ? Colors.white : Colors.primaries[index % Colors.primaries.length].shade200,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _revealed[index] ? _gameBoard[index] : '',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.primaries[index % Colors.primaries.length].shade900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
