import 'dart:async';

/// Bộ đệm chia sẻ ngắn hạn và gom nhóm các request GET trùng lặp đang chạy (request coalescing).
/// - Mọi dữ liệu đều gắn theo định danh tài khoản (userScope) để không bao giờ rò rỉ giữa các tài khoản.
/// - Tự động vô hiệu hóa toàn bộ hoặc theo prefix khi có thao tác ghi (POST/PUT/DELETE) hoặc đổi tài khoản.
class DataCacheService {
  DataCacheService._();
  static final DataCacheService instance = DataCacheService._();

  static const Duration defaultTtl = Duration(seconds: 20);

  String _userScope = 'guest';
  final Map<String, _CacheEntry> _cache = {};
  final Map<String, Future<dynamic>> _inFlight = {};

  void setUserScope(String? scope) {
    final normalized = (scope ?? '').trim().toLowerCase();
    final nextScope = normalized.isEmpty ? 'guest' : normalized;
    if (_userScope != nextScope) {
      _userScope = nextScope;
      _cache.clear();
      _inFlight.clear();
    }
  }

  String _scopedKey(String key) => '$_userScope::$key';

  /// Gom các request giống nhau đang chạy song song và dùng lại dữ liệu còn hạn (nếu forceRefresh == false).
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration ttl = defaultTtl,
    bool forceRefresh = false,
  }) async {
    final sKey = _scopedKey(key);

    if (!forceRefresh) {
      final entry = _cache[sKey];
      if (entry != null && DateTime.now().isBefore(entry.expiresAt)) {
        return entry.value as T;
      }

      final existingFuture = _inFlight[sKey];
      if (existingFuture != null) {
        final res = await existingFuture;
        return res as T;
      }
    }

    final future = fetcher();
    _inFlight[sKey] = future;
    try {
      final result = await future;
      _cache[sKey] = _CacheEntry(
        value: result,
        expiresAt: DateTime.now().add(ttl),
      );
      return result;
    } finally {
      if (identical(_inFlight[sKey], future)) {
        _inFlight.remove(sKey);
      }
    }
  }

  void invalidateKey(String key) {
    final sKey = _scopedKey(key);
    _cache.remove(sKey);
    _inFlight.remove(sKey);
  }

  void invalidatePrefix(String prefix) {
    final scopedPrefix = '$_userScope::$prefix';
    _cache.removeWhere((k, _) => k.startsWith(scopedPrefix));
    _inFlight.removeWhere((k, _) => k.startsWith(scopedPrefix));
  }

  void invalidateAll() {
    _cache.clear();
    _inFlight.clear();
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  const _CacheEntry({required this.value, required this.expiresAt});
}
