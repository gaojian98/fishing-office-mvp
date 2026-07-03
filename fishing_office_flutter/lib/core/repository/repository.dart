abstract class Repository<T> {
  Future<T> load();
}

abstract class CacheRepository<T> implements Repository<T> {
  T? get cachedValue;
  Future<void> save(T value);
}

