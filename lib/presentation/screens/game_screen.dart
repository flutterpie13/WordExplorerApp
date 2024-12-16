import 'package:flutter/material.dart';
import '../../services/card_manager.dart';
import '../../domain/entities/card.dart';
import '../widgets/flip_card.dart';

class GameScreen extends StatefulWidget {
  final int selectedClass;
  final String selectedTopic;
  final String selectedWordType;
  final String selectedDifficulty;

  GameScreen({
    required this.selectedClass,
    required this.selectedTopic,
    required this.selectedWordType,
    required this.selectedDifficulty,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardModel> _cards = [];
  final Set<int> _flippedCards = {};
  final Set<int> _matchedCards = {};
  bool _isInteractionLocked = false;

  late int _selectedClass;
  late String _selectedTopic;
  late String _selectedWordType;
  late String _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.selectedClass;
    _selectedTopic = widget.selectedTopic;
    _selectedWordType = widget.selectedWordType;
    _selectedDifficulty = widget.selectedDifficulty;

    _loadCards();
  }

  Future<void> _loadCards() async {
    final cardManager = CardManager();
    await cardManager.loadCards();
    setState(() {
      _cards = cardManager.filterCards(
        classLevel: _selectedClass,
        topic: _selectedTopic,
        wordType: _selectedWordType,
      );
      _cards.shuffle();
    });
  }

  void _checkMatch() {
    if (_flippedCards.length == 2) {
      final firstIndex = _flippedCards.first;
      final secondIndex = _flippedCards.last;

      final card1 = _cards[firstIndex];
      final card2 = _cards[secondIndex];

      final isMatch = card1.pairId == card2.pairId;

      setState(() {
        if (isMatch) {
          _matchedCards.addAll([firstIndex, secondIndex]);
        } else {
          _isInteractionLocked = true;
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _flippedCards.clear();
              _isInteractionLocked = false;
            });
          });
        }
      });
    }
  }

  void _resetGame() {
    setState(() {
      _flippedCards.clear();
      _matchedCards.clear();
      _isInteractionLocked = false;
      _loadCards();
    });
  }

  void _exitGame() {
    Navigator.of(context).pop();
  }

  void _showAdjustDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Spiel anpassen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedTopic,
                items: ['school', 'home', 'food', 'all'].map((topic) {
                  return DropdownMenuItem(
                    value: topic,
                    child: Text(topic),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTopic = value;
                    });
                  }
                },
              ),
              DropdownButton<String>(
                value: _selectedWordType,
                items: ['noun', 'verb', 'all'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedWordType = value;
                    });
                  }
                },
              ),
              DropdownButton<String>(
                value: _selectedDifficulty,
                items: ['easy', 'medium', 'hard'].map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Anwenden'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Explorer - Spiel'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'exit') {
                _exitGame();
              } else if (value == 'adjust') {
                _showAdjustDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'exit',
                child: Text('Spiel verlassen'),
              ),
              const PopupMenuItem(
                value: 'adjust',
                child: Text('Spiel anpassen'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: _cards.isEmpty
            ? const CircularProgressIndicator()
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return FlipCard(
                    frontContent: card.content,
                    isFlipped: _flippedCards.contains(index) ||
                        _matchedCards.contains(index),
                    onTap: () {
                      if (_isInteractionLocked ||
                          _flippedCards.contains(index) ||
                          _matchedCards.contains(index)) {
                        return;
                      }

                      setState(() {
                        _flippedCards.add(index);
                        if (_flippedCards.length == 2) {
                          _checkMatch();
                        }
                      });
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetGame,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
