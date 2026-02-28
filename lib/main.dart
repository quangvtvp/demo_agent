import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user_preferences.dart';
import 'services/cache_service.dart';
import 'services/gemini_service.dart';

late final GeminiService geminiService;
late final CacheService cacheService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // ── Khởi tạo Hive (hỗ trợ cả mobile & web) ──
  await Hive.initFlutter();

  // ── Khởi tạo services ──
  cacheService = CacheService();
  await cacheService.init();

  geminiService = GeminiService(
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    cacheService: cacheService,
  );

  await _testGeminiServiceWithCache();

  runApp(const MainApp());
}

/// Test gọi Gemini service với cache/realtime mode.
Future<void> _testGeminiServiceWithCache() async {
  final preferences = UserPreferences(
    originLocation: 'Hà Nội, Việt Nam',
    durationDays: 3,
    budget: BudgetAmount(
      amount: 5000000,
      currency: 'VND',
      displayText: '~5M VNĐ / người',
    ),
    travelStyle: ['biển', 'nghỉ dưỡng', 'thiên nhiên'],
    departureDate: '2025-03-15',
  );

  // ── Test 1: Gọi REALTIME (luôn gọi API) ────────────────────────────
  log('═══════════════════════════════════════════');
  log('>>> [TEST 1] getTravelSuggestions — REALTIME (limit=3)');
  log('═══════════════════════════════════════════');
  try {
    final stopwatch = Stopwatch()..start();
    final suggestions = await geminiService.getTravelSuggestions(
      preferences,
      limit: 3,
      realtime: true,
    );
    stopwatch.stop();

    log('⏱ Thời gian: ${stopwatch.elapsedMilliseconds}ms');
    log('contextSummary: ${suggestions.contextSummary}');
    log('Số gợi ý: ${suggestions.suggestions.length}');
    for (int i = 0; i < suggestions.suggestions.length; i++) {
      final s = suggestions.suggestions[i];
      log(
        '[${i + 1}] ${s.name}, ${s.country} '
        '(matchScore: ${s.matchScore}%)',
      );
    }

    // ── Test 2: Gọi CACHED (đọc từ cache) ───────────────────────────
    log('');
    log('═══════════════════════════════════════════');
    log('>>> [TEST 2] getTravelSuggestions — CACHED (same preferences)');
    log('═══════════════════════════════════════════');
    final stopwatch2 = Stopwatch()..start();
    final cachedSuggestions = await geminiService.getTravelSuggestions(
      preferences,
      limit: 3,
      realtime: false, // <— sẽ đọc từ cache
    );
    stopwatch2.stop();

    log('⏱ Thời gian: ${stopwatch2.elapsedMilliseconds}ms');
    log('Số gợi ý: ${cachedSuggestions.suggestions.length}');
    for (int i = 0; i < cachedSuggestions.suggestions.length; i++) {
      final s = cachedSuggestions.suggestions[i];
      log('[${i + 1}] ${s.name}, ${s.country}');
    }
    log('');
    log('[TEST] Hoàn thành ✅ — Cache hoạt động!');
  } catch (e, stack) {
    log('[TEST] Lỗi: $e', error: e, stackTrace: stack);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('AI Travel - Demo Agent'))),
    );
  }
}
