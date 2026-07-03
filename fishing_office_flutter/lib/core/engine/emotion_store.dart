import 'dart:async';

import 'companion_gift_manager.dart';
import 'decoration_manager.dart';
import 'music_manager.dart';
import 'album_manager.dart';

typedef EmotionStoreListener = void Function(EmotionProduct product);

class EmotionStore {
  EmotionStore({
    DecorationManager? decorationManager,
    MusicManager? musicManager,
    AlbumManager? albumManager,
    CompanionGiftManager? companionGiftManager,
    List<EmotionStoreListener> listeners = const [],
  })  : decorationManager = decorationManager ?? const DecorationManager(),
        musicManager = musicManager ?? const MusicManager(),
        albumManager = albumManager ?? const AlbumManager(),
        companionGiftManager =
            companionGiftManager ?? const CompanionGiftManager(),
        _listeners = List<EmotionStoreListener>.from(listeners);

  final DecorationManager decorationManager;
  final MusicManager musicManager;
  final AlbumManager albumManager;
  final CompanionGiftManager companionGiftManager;
  final List<EmotionStoreListener> _listeners;
  final StreamController<EmotionProduct> _productController =
      StreamController<EmotionProduct>.broadcast();

  Stream<EmotionProduct> get products => _productController.stream;

  EmotionProduct publish(EmotionProduct product) {
    for (final listener in List<EmotionStoreListener>.from(_listeners)) {
      listener(product);
    }
    _productController.add(product);
    return product;
  }

  EmotionProduct buildDecoration({
    required String productId,
    required String name,
    required String category,
    required int price,
    required String description,
    Map<String, dynamic> context = const {},
  }) {
    return publish(
      decorationManager.build(
        productId: productId,
        name: name,
        category: category,
        price: price,
        description: description,
        context: context,
      ),
    );
  }

  EmotionProduct buildMusic({
    required String productId,
    required String name,
    required String category,
    required int price,
    required String description,
    Map<String, dynamic> context = const {},
  }) {
    return publish(
      musicManager.build(
        productId: productId,
        name: name,
        category: category,
        price: price,
        description: description,
        context: context,
      ),
    );
  }

  EmotionProduct buildAlbum({
    required String productId,
    required String name,
    required String category,
    required int price,
    required String description,
    Map<String, dynamic> context = const {},
  }) {
    return publish(
      albumManager.build(
        productId: productId,
        name: name,
        category: category,
        price: price,
        description: description,
        context: context,
      ),
    );
  }

  EmotionProduct buildCompanionGift({
    required String productId,
    required String name,
    required String category,
    required int price,
    required String description,
    Map<String, dynamic> context = const {},
  }) {
    return publish(
      companionGiftManager.build(
        productId: productId,
        name: name,
        category: category,
        price: price,
        description: description,
        context: context,
      ),
    );
  }

  Future<void> dispose() async {
    await _productController.close();
  }
}

class EmotionProduct {
  const EmotionProduct({
    required this.productId,
    required this.productType,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.effects,
    required this.context,
  });

  final String productId;
  final String productType;
  final String name;
  final String category;
  final int price;
  final String description;
  final List<String> effects;
  final Map<String, dynamic> context;
}
