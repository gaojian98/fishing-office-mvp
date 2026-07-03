import 'emotion_store.dart';

class AlbumManager {
  const AlbumManager();

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
      productType: 'album',
      name: name,
      category: category,
      price: price,
      description: description,
      effects: const ['memory'],
      context: context,
    );
  }
}
