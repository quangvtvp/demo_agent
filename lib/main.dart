import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/user_preferences.dart';
import 'services/gemini_service.dart';

late final GeminiService geminiService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  geminiService = GeminiService(apiKey: dotenv.env['GEMINI_API_KEY'] ?? '');

  await _testGeminiService();

  runApp(const MainApp());
}

/// Test gọi Gemini service và in kết quả ra console.
Future<void> _testGeminiService() async {
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

  // ── Test 1: Gợi ý điểm đến (limit = 3 để test nhanh) ──────────────
  log('═══════════════════════════════════════════');
  log('>>> [TEST] getTravelSuggestions (limit=3)');
  log('═══════════════════════════════════════════');
  try {
    final suggestions = await geminiService.getTravelSuggestions(
      preferences,
      limit: 3,
    );

    log('contextSummary: ${suggestions.contextSummary}');
    log('generatedAt: ${suggestions.generatedAt}');
    log('Số gợi ý nhận được: ${suggestions.suggestions.length}');
    log('───────────────────────────────────────────');

    for (int i = 0; i < suggestions.suggestions.length; i++) {
      final s = suggestions.suggestions[i];
      log('[${i + 1}] ${s.name}, ${s.country}');
      log(
        '    matchScore : ${s.matchScore}%${s.isTopPick ? ' 🎯 Top Pick' : ''}',
      );
      log('    budget     : ${s.estimatedBudget.displayText}');
      log('    aiInsight  : ${s.aiInsight}');
      log('    tags       : ${s.tags.join(', ')}');
      log('    imageUrl   : ${s.imageUrl}');
      log('───────────────────────────────────────────');
    }

    // ── Test 2: Chi tiết điểm đến đầu tiên ─────────────────────────
    if (suggestions.suggestions.isNotEmpty) {
      final firstId = suggestions.suggestions.first.destinationId;
      log('');
      log('>>> [TEST] getDestinationDetail (id=$firstId)');
      log('═══════════════════════════════════════════');

      final detail = await geminiService.getDestinationDetail(
        firstId,
        preferences,
      );

      log('Điểm đến    : ${detail.destination.fullDisplayName}');
      log('Thời tiết   : ${detail.weather.displayText}');
      log('Ngày đi     : ${detail.travelDates.displayText}');
      log('Ngân sách   : ${detail.budget.total.displayText}');
      log('aiInsight   : ${detail.aiInsight}');
      log('');
      log('── Budget Breakdown ──────────────────────');
      for (final item in detail.budget.breakdown) {
        log('  ${item.label}: ${item.displayText}');
      }
      log('');
      log('── Lịch trình ────────────────────────────');
      for (final day in detail.itinerary) {
        log('  ${day.dayLabel}');
        for (final act in day.activities) {
          log(
            '    ${act.time} | ${act.title} (${act.estimatedDurationMinutes} phút)',
          );
        }
      }
      log('');
      log('── Highlights ────────────────────────────');
      for (final h in detail.highlights) {
        log('  • ${h.title}: ${h.description}');
      }
      log('═══════════════════════════════════════════');
      log('[TEST] Hoàn thành ✅');
    }
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
