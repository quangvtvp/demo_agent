import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/destination_detail_response.dart';
import '../models/travel_suggestions_response.dart';
import '../models/user_preferences.dart';
import 'cache_service.dart';

/// Service gọi Gemini API để sinh gợi ý du lịch và lịch trình chi tiết.
///
/// Hỗ trợ 2 chế độ:
/// - **realtime** (`realtime = true`): luôn gọi API, cache kết quả mới.
/// - **cached** (`realtime = false`, mặc định): ưu tiên đọc cache,
///   chỉ gọi API nếu cache trống/hết hạn.
///
/// Tất cả nội dung trả về đều bằng tiếng Việt.
/// Image URLs được yêu cầu Gemini trả về dạng link Unsplash thực tế.
class GeminiService {
  final GenerativeModel _model;
  final CacheService _cacheService;
  final int defaultLimit;

  GeminiService({
    required String apiKey,
    required CacheService cacheService,
    this.defaultLimit = 10,
  }) : _model = GenerativeModel(
         model: 'gemini-3-flash-preview',
         apiKey: apiKey,
         generationConfig: GenerationConfig(
           responseMimeType: 'application/json',
           temperature: 0.7,
         ),
       ),
       _cacheService = cacheService;

  // ---------------------------------------------------------------------------
  // 1) Gợi ý điểm đến
  // ---------------------------------------------------------------------------

  /// Trả về danh sách gợi ý điểm đến du lịch phù hợp với [preferences].
  ///
  /// [limit] – số lượng kết quả tối đa (mặc định [defaultLimit] = 10).
  /// [realtime] – `true` để luôn gọi API mới, `false` để ưu tiên cache.
  Future<TravelSuggestionsResponse> getTravelSuggestions(
    UserPreferences preferences, {
    int? limit,
    bool realtime = false,
  }) async {
    final effectiveLimit = limit ?? defaultLimit;
    final cacheKey = '${preferences.cacheKey}_$effectiveLimit';

    // ── Cached mode: kiểm tra cache trước ──
    if (!realtime) {
      final cached = _cacheService.getCachedSuggestions(cacheKey);
      if (cached != null) {
        log('[GeminiService] ✅ Suggestions loaded from CACHE');
        return cached;
      }
      log('[GeminiService] Cache miss — fallback to API');
    } else {
      log('[GeminiService] 🔄 Realtime mode — calling API');
    }

    // ── Gọi API ──
    final prompt = _buildSuggestionsPrompt(preferences, effectiveLimit);
    final response = await _model.generateContent([Content.text(prompt)]);

    final jsonText = response.text;
    if (jsonText == null || jsonText.isEmpty) {
      throw Exception('Gemini API trả về kết quả rỗng.');
    }

    final jsonMap = json.decode(jsonText) as Map<String, dynamic>;
    final result = TravelSuggestionsResponse.fromJson(jsonMap);

    // ── Cache kết quả ──
    await _cacheService.cacheSuggestions(cacheKey, result);
    log('[GeminiService] 💾 Suggestions cached — key: $cacheKey');

    return result;
  }

  String _buildSuggestionsPrompt(UserPreferences prefs, int limit) {
    return '''
Bạn là một chuyên gia du lịch AI. Hãy gợi ý $limit điểm đến du lịch phù hợp nhất dựa trên thông tin sau:

- Điểm xuất phát: ${prefs.originLocation}
- Số ngày: ${prefs.durationDays} ngày
- Ngân sách: ${prefs.budget.amount} ${prefs.budget.currency} / người
- Phong cách: ${prefs.travelStyle.join(', ')}
- Ngày khởi hành: ${prefs.departureDate}

YÊU CẦU:
1. Trả về đúng $limit điểm đến, sắp xếp theo matchScore giảm dần.
2. Tất cả nội dung (displayText, aiInsight, tags) phải bằng TIẾNG VIỆT.
3. matchScore là số nguyên 0-100 thể hiện mức độ phù hợp.
4. isTopPick = true cho điểm đến có matchScore cao nhất.
5. Mỗi imageUrl phải là link ảnh thực từ Unsplash (dạng https://images.unsplash.com/photo-...) phù hợp với điểm đến.
6. estimatedBudget.displayText theo format "~X.XM VNĐ / người" hoặc "~XXXK VNĐ / người".
7. tags là danh sách 2-4 tag mô tả đặc điểm (VD: ["biển", "nghỉ dưỡng", "thiên nhiên"]).
8. aiInsight là 1-2 câu ngắn gọn giải thích tại sao điểm đến phù hợp.

Trả về JSON theo đúng schema sau (KHÔNG thêm gì ngoài JSON):
{
  "contextSummary": "<điểm xuất phát> · <N> ngày · Ngân sách <X>M VNĐ",
  "suggestions": [
    {
      "destinationId": "<slug-dạng-lowercase>",
      "name": "<tên địa danh>",
      "country": "<quốc gia>",
      "imageUrl": "<link ảnh Unsplash thực>",
      "matchScore": <0-100>,
      "isTopPick": <true/false>,
      "estimatedBudget": {
        "amount": <số nguyên VND>,
        "currency": "VND",
        "displayText": "<~X.XM VNĐ / người>"
      },
      "aiInsight": "<nhận xét tiếng Việt>",
      "tags": ["<tag1>", "<tag2>"]
    }
  ],
  "generatedAt": "${DateTime.now().toUtc().toIso8601String()}"
}
''';
  }

  // ---------------------------------------------------------------------------
  // 2) Chi tiết điểm đến & lịch trình
  // ---------------------------------------------------------------------------

  /// Trả về thông tin chi tiết và lịch trình day-by-day cho [destinationId].
  ///
  /// [realtime] – `true` để luôn gọi API mới, `false` để ưu tiên cache.
  Future<DestinationDetailResponse> getDestinationDetail(
    String destinationId,
    UserPreferences preferences, {
    bool realtime = false,
  }) async {
    final cacheKey = '${destinationId}_${preferences.cacheKey}';

    // ── Cached mode: kiểm tra cache trước ──
    if (!realtime) {
      final cached = _cacheService.getCachedDetail(cacheKey);
      if (cached != null) {
        log('[GeminiService] ✅ Detail loaded from CACHE');
        return cached;
      }
      log('[GeminiService] Cache miss — fallback to API');
    } else {
      log('[GeminiService] 🔄 Realtime mode — calling API');
    }

    // ── Gọi API ──
    final prompt = _buildDetailPrompt(destinationId, preferences);
    final response = await _model.generateContent([Content.text(prompt)]);

    final jsonText = response.text;
    if (jsonText == null || jsonText.isEmpty) {
      throw Exception('Gemini API trả về kết quả rỗng.');
    }

    final jsonMap = json.decode(jsonText) as Map<String, dynamic>;
    final result = DestinationDetailResponse.fromJson(jsonMap);

    // ── Cache kết quả ──
    await _cacheService.cacheDetail(cacheKey, result);
    log('[GeminiService] 💾 Detail cached — key: $cacheKey');

    return result;
  }

  String _buildDetailPrompt(String destinationId, UserPreferences prefs) {
    return '''
Bạn là một chuyên gia du lịch AI. Hãy tạo lịch trình chi tiết cho điểm đến sau:

- Điểm đến: $destinationId
- Điểm xuất phát: ${prefs.originLocation}
- Số ngày: ${prefs.durationDays} ngày
- Ngân sách: ${prefs.budget.amount} ${prefs.budget.currency} / người
- Phong cách: ${prefs.travelStyle.join(', ')}
- Ngày khởi hành: ${prefs.departureDate}

YÊU CẦU:
1. Tất cả nội dung phải bằng TIẾNG VIỆT.
2. Tất cả imageUrl (heroImageUrl, galleryImageUrls, highlight imageUrl) phải là link ảnh thực từ Unsplash phù hợp với nội dung.
3. weather: dự báo thời tiết thực tế cho thời điểm khởi hành.
4. budget.breakdown gồm 4 hạng mục: lưu trú, ăn uống, di chuyển, hoạt động. Tổng breakdown = total.
5. itinerary: lịch trình theo từng ngày, mỗi ngày 3-5 hoạt động, mỗi hoạt động có time (HH:mm), title, description tiếng Việt.
6. highlights: 2-4 điểm nổi bật must-see của điểm đến.
7. aiInsight: 1-2 câu nhận xét chung tiếng Việt.

Trả về JSON theo đúng schema sau (KHÔNG thêm gì ngoài JSON):
{
  "destination": {
    "id": "<slug>",
    "name": "<tên>",
    "country": "<quốc gia>",
    "fullDisplayName": "<tên>, <quốc gia>",
    "heroImageUrl": "<link Unsplash>",
    "galleryImageUrls": ["<link1>", "<link2>"],
    "description": "<mô tả tiếng Việt>",
    "tags": ["<tag1>", "<tag2>"]
  },
  "weather": {
    "condition": "<Nắng/Mưa/...>",
    "temperatureCelsius": <số>,
    "displayText": "<Nắng, 32°C>",
    "icon": "<sunny/rainy/cloudy/...>"
  },
  "travelDates": {
    "startDate": "<YYYY-MM-DD>",
    "endDate": "<YYYY-MM-DD>",
    "displayText": "<DD/MM - DD/MM>",
    "durationDays": ${prefs.durationDays}
  },
  "budget": {
    "total": {
      "amount": <số>,
      "currency": "VND",
      "displayText": "<~X.XM VNĐ>"
    },
    "breakdown": [
      {
        "category": "accommodation",
        "label": "Lưu trú",
        "amount": <số>,
        "currency": "VND",
        "displayText": "<~X.XM VNĐ>",
        "icon": "hotel"
      }
    ]
  },
  "itinerary": [
    {
      "dayNumber": 1,
      "date": "<YYYY-MM-DD>",
      "dayLabel": "Ngày 1 — <chủ đề>",
      "activities": [
        {
          "id": "<unique-id>",
          "time": "<HH:mm>",
          "title": "<tiêu đề tiếng Việt>",
          "description": "<mô tả tiếng Việt>",
          "category": "<loại>",
          "icon": "<icon>",
          "estimatedDurationMinutes": <số>
        }
      ]
    }
  ],
  "highlights": [
    {
      "id": "<id>",
      "title": "<tên tiếng Việt>",
      "description": "<mô tả tiếng Việt>",
      "imageUrl": "<link Unsplash>",
      "category": "<loại>"
    }
  ],
  "aiInsight": "<nhận xét tiếng Việt>",
  "matchScore": <0-100>,
  "isSaved": false,
  "generatedAt": "${DateTime.now().toUtc().toIso8601String()}"
}
''';
  }
}
