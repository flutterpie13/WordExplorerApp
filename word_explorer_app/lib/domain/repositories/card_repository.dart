import '../entities/card_pair.dart';

abstract class CardRepository {
  Future<List<CardPair>> getCardPairs();
}
