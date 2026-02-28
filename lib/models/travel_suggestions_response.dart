import 'user_preferences.dart';

class DestinationSuggestion {
  final String destinationId;
  final String name;
  final String country;
  final String imageUrl;
  final int matchScore;
  final bool isTopPick;
  final BudgetAmount estimatedBudget;
  final String aiInsight;
  final List<String> tags;

  const DestinationSuggestion({
    required this.destinationId,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.matchScore,
    required this.isTopPick,
    required this.estimatedBudget,
    required this.aiInsight,
    required this.tags,
  });

  factory DestinationSuggestion.fromJson(Map<String, dynamic> json) {
    return DestinationSuggestion(
      destinationId: json['destinationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 0,
      isTopPick: json['isTopPick'] as bool? ?? false,
      estimatedBudget: json['estimatedBudget'] != null
          ? BudgetAmount.fromJson(
              json['estimatedBudget'] as Map<String, dynamic>,
            )
          : const BudgetAmount(amount: 0, currency: 'VND', displayText: 'N/A'),
      aiInsight: json['aiInsight'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'destinationId': destinationId,
    'name': name,
    'country': country,
    'imageUrl': imageUrl,
    'matchScore': matchScore,
    'isTopPick': isTopPick,
    'estimatedBudget': estimatedBudget.toJson(),
    'aiInsight': aiInsight,
    'tags': tags,
  };
}

class TravelSuggestionsResponse {
  final String contextSummary;
  final List<DestinationSuggestion> suggestions;
  final String generatedAt;

  const TravelSuggestionsResponse({
    required this.contextSummary,
    required this.suggestions,
    required this.generatedAt,
  });

  factory TravelSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return TravelSuggestionsResponse(
      contextSummary: json['contextSummary'] as String? ?? '',
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DestinationSuggestion.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      generatedAt: json['generatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'contextSummary': contextSummary,
    'suggestions': suggestions.map((e) => e.toJson()).toList(),
    'generatedAt': generatedAt,
  };
}
