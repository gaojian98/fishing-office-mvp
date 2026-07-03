class JsonCacheEntry {
  JsonCacheEntry(this.value, {DateTime? updatedAt}) : updatedAt = updatedAt ?? DateTime.now();

  final Map<String, dynamic> value;
  final DateTime updatedAt;
}

class JsonMemoryCache {
  final Map<String, JsonCacheEntry> _entries = {};

  JsonCacheEntry? read(String key) => _entries[key];

  void write(String key, Map<String, dynamic> value) {
    _entries[key] = JsonCacheEntry(value);
  }

  void clear() => _entries.clear();
}

