class CardPair {
  final String word; // Das englische Wort
  final String sceneDescription; // Beschreibung der Szene
  final String sceneImagePath; // Pfad zum Bild
  final String wordType; // Nomen, Verb oder Adjektiv
  final String category; // Kategorie: Tiere, Essen etc.

  CardPair({
    required this.word,
    required this.sceneDescription,
    required this.sceneImagePath,
    required this.wordType,
    required this.category,
  });
}
