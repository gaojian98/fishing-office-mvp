import 'emotion_store.dart';

class CompanionGiftManager {
  const CompanionGiftManager();

  EmotionProduct build({
    required String productId,
    required String name,
    required String category,
    required int price,
    required String description,
    Map<String, dynamic> context = const {},
  }) {
    return EmotionProduct(
      productId: productId,
      productType: 'companionGift',
      name: name,
      category: category,
      price: price,
      description: description,
      effects: const ['interaction'],
      context: context,
    );
  }
}
