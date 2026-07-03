import 'emotion_store.dart';

class MusicManager {
  const MusicManager();

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
      productType: 'music',
      name: name,
      category: category,
      price: price,
      description: description,
      effects: const ['soundscape'],
      context: context,
    );
  }
}
