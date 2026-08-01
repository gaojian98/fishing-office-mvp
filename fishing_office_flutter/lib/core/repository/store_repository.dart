import '../../models/store_config.dart';
import '../../services/store_config_loader.dart';
import 'repository.dart';

class StoreRepository implements CacheRepository<StoreConfigBundle> {
  StoreRepository({
    StoreConfigLoader? loader,
  }) : _loader = loader ?? const StoreConfigLoader();

  final StoreConfigLoader _loader;
  StoreConfigBundle? _cachedValue;

  @override
  StoreConfigBundle? get cachedValue => _cachedValue;

  @override
  Future<StoreConfigBundle> load() async {
    if (_cachedValue != null) return _cachedValue!;
    final bundle = await _loader.load();
    _cachedValue = bundle;
    return bundle;
  }

  @override
  Future<void> save(StoreConfigBundle value) async {
    _cachedValue = value;
  }

  Future<StoreConfigBundle> refresh() async {
    final bundle = await _loader.load();
    _cachedValue = bundle;
    return bundle;
  }

  List<StoreCategory> getCategories({bool onlyEnabled = true}) {
    final categories = _cachedValue?.data.categories ?? const <StoreCategory>[];
    final filtered =
        onlyEnabled ? categories.where((item) => item.enabled) : categories;
    return [...filtered]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<StoreProduct> getProducts({
    bool onlyEnabled = true,
    String? categoryId,
  }) {
    final products = _cachedValue?.data.products ?? const <StoreProduct>[];
    final filtered = products.where((item) {
      if (onlyEnabled && !item.enabled) return false;
      if (categoryId == null ||
          categoryId.isEmpty ||
          categoryId == 'recommend') {
        return true;
      }
      return item.category == categoryId;
    });
    return [...filtered]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  StoreProduct? productById(String productId) {
    for (final product
        in _cachedValue?.data.products ?? const <StoreProduct>[]) {
      if (product.id == productId) return product;
    }
    return null;
  }

  StoreCategory? categoryById(String categoryId) {
    for (final category
        in _cachedValue?.data.categories ?? const <StoreCategory>[]) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  void clearCache() {
    _cachedValue = null;
  }
}
