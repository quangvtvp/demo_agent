import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';

import '../models/destination_detail_response.dart';
import '../models/travel_suggestions_response.dart';

/// Service quản lý cache dữ liệu từ Gemini API bằng Hive.
///
/// Hive lưu dữ liệu dưới dạng JSON string, hỗ trợ tốt trên cả mobile và web.
/// Mỗi entry được lưu kèm timestamp để kiểm tra hết hạn.
class CacheService {
  static const String _suggestionsBoxName = 'suggestions_cache';
  static const String _detailsBoxName = 'details_cache';
  static const String _timestampSuffix = '__ts';

  late Box<String> _suggestionsBox;
  late Box<String> _detailsBox;

  /// Mặc định cache hết hạn sau 24 giờ.
  final Duration maxCacheAge;

  CacheService({this.maxCacheAge = const Duration(hours: 24)});

  /// Khởi tạo và mở các Hive boxes. Gọi 1 lần khi app khởi động.
  Future<void> init() async {
    _suggestionsBox = await Hive.openBox<String>(_suggestionsBoxName);
    _detailsBox = await Hive.openBox<String>(_detailsBoxName);
    log(
      '[CacheService] Initialized — '
      'suggestions: ${_suggestionsBox.length} entries, '
      'details: ${_detailsBox.length} entries',
    );
  }

  // ---------------------------------------------------------------------------
  // Suggestions cache
  // ---------------------------------------------------------------------------

  /// Lưu [response] vào cache với [cacheKey].
  Future<void> cacheSuggestions(
    String cacheKey,
    TravelSuggestionsResponse response,
  ) async {
    final jsonString = json.encode(response.toJson());
    await _suggestionsBox.put(cacheKey, jsonString);
    await _suggestionsBox.put(
      '$cacheKey$_timestampSuffix',
      DateTime.now().toUtc().toIso8601String(),
    );
    log('[CacheService] Cached suggestions — key: $cacheKey');
  }

  /// Lấy suggestions từ cache. Trả về `null` nếu không có hoặc đã hết hạn.
  TravelSuggestionsResponse? getCachedSuggestions(String cacheKey) {
    if (_isCacheExpired(_suggestionsBox, cacheKey)) return null;

    final jsonString = _suggestionsBox.get(cacheKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      log('[CacheService] Loaded suggestions from cache — key: $cacheKey');
      return TravelSuggestionsResponse.fromJson(jsonMap);
    } catch (e) {
      log('[CacheService] Lỗi parse suggestions cache: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Destination detail cache
  // ---------------------------------------------------------------------------

  /// Lưu [response] vào cache với [cacheKey] (thường là destinationId).
  Future<void> cacheDetail(
    String cacheKey,
    DestinationDetailResponse response,
  ) async {
    final jsonString = json.encode(response.toJson());
    await _detailsBox.put(cacheKey, jsonString);
    await _detailsBox.put(
      '$cacheKey$_timestampSuffix',
      DateTime.now().toUtc().toIso8601String(),
    );
    log('[CacheService] Cached detail — key: $cacheKey');
  }

  /// Lấy detail từ cache. Trả về `null` nếu không có hoặc đã hết hạn.
  DestinationDetailResponse? getCachedDetail(String cacheKey) {
    if (_isCacheExpired(_detailsBox, cacheKey)) return null;

    final jsonString = _detailsBox.get(cacheKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      log('[CacheService] Loaded detail from cache — key: $cacheKey');
      return DestinationDetailResponse.fromJson(jsonMap);
    } catch (e) {
      log('[CacheService] Lỗi parse detail cache: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  /// Xóa toàn bộ cache.
  Future<void> clearAll() async {
    await _suggestionsBox.clear();
    await _detailsBox.clear();
    log('[CacheService] Cleared all cache');
  }

  /// Kiểm tra cache có hết hạn hay chưa.
  bool _isCacheExpired(Box<String> box, String cacheKey) {
    final tsString = box.get('$cacheKey$_timestampSuffix');
    if (tsString == null) return true;

    try {
      final cachedAt = DateTime.parse(tsString);
      final age = DateTime.now().toUtc().difference(cachedAt);
      return age > maxCacheAge;
    } catch (_) {
      return true;
    }
  }
}
