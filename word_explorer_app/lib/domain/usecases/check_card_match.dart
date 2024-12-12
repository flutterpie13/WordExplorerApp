import '../entities/card_pair.dart';
import 'difficulty_level.dart';

class CheckCardMatch {
  final DifficultyLevel difficultyLevel;

  CheckCardMatch(this.difficultyLevel);

  bool execute(CardPair card1, CardPair card2) {
    // Matching-Logik basierend auf der Schwierigkeit
    if (card1.word != card2.word) {
      return false;
    }

    if (difficultyLevel.difficulty == Difficulty.medium &&
        card1.wordType != card2.wordType) {
      return false;
    }

    // Für 'Schwer' könnten zusätzliche Bedingungen hinzugefügt werden
    return true;
  }
}
