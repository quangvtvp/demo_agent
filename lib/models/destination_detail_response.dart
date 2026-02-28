import 'user_preferences.dart';

class DestinationInfo {
  final String id;
  final String name;
  final String country;
  final String fullDisplayName;
  final String heroImageUrl;
  final List<String> galleryImageUrls;
  final String description;
  final List<String> tags;

  const DestinationInfo({
    required this.id,
    required this.name,
    required this.country,
    required this.fullDisplayName,
    required this.heroImageUrl,
    required this.galleryImageUrls,
    required this.description,
    required this.tags,
  });

  factory DestinationInfo.fromJson(Map<String, dynamic> json) {
    return DestinationInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      fullDisplayName: json['fullDisplayName'] as String? ?? '',
      heroImageUrl: json['heroImageUrl'] as String? ?? '',
      galleryImageUrls:
          (json['galleryImageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'fullDisplayName': fullDisplayName,
    'heroImageUrl': heroImageUrl,
    'galleryImageUrls': galleryImageUrls,
    'description': description,
    'tags': tags,
  };
}

class WeatherInfo {
  final String condition;
  final int temperatureCelsius;
  final String displayText;
  final String icon;

  const WeatherInfo({
    required this.condition,
    required this.temperatureCelsius,
    required this.displayText,
    required this.icon,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      condition: json['condition'] as String? ?? '',
      temperatureCelsius: (json['temperatureCelsius'] as num?)?.toInt() ?? 0,
      displayText: json['displayText'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'condition': condition,
    'temperatureCelsius': temperatureCelsius,
    'displayText': displayText,
    'icon': icon,
  };
}

class TravelDates {
  final String startDate;
  final String endDate;
  final String displayText;
  final int durationDays;

  const TravelDates({
    required this.startDate,
    required this.endDate,
    required this.displayText,
    required this.durationDays,
  });

  factory TravelDates.fromJson(Map<String, dynamic> json) {
    return TravelDates(
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      displayText: json['displayText'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'startDate': startDate,
    'endDate': endDate,
    'displayText': displayText,
    'durationDays': durationDays,
  };
}

class BudgetItem {
  final String category;
  final String label;
  final int amount;
  final String currency;
  final String displayText;
  final String icon;

  const BudgetItem({
    required this.category,
    required this.label,
    required this.amount,
    required this.currency,
    required this.displayText,
    required this.icon,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      category: json['category'] as String? ?? '',
      label: json['label'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
      displayText: json['displayText'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'label': label,
    'amount': amount,
    'currency': currency,
    'displayText': displayText,
    'icon': icon,
  };
}

class BudgetInfo {
  final BudgetAmount total;
  final List<BudgetItem> breakdown;

  const BudgetInfo({required this.total, required this.breakdown});

  factory BudgetInfo.fromJson(Map<String, dynamic> json) {
    return BudgetInfo(
      total: json['total'] != null
          ? BudgetAmount.fromJson(json['total'] as Map<String, dynamic>)
          : const BudgetAmount(amount: 0, currency: 'VND', displayText: 'N/A'),
      breakdown:
          (json['breakdown'] as List<dynamic>?)
              ?.map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total.toJson(),
    'breakdown': breakdown.map((e) => e.toJson()).toList(),
  };
}

class Activity {
  final String id;
  final String time;
  final String title;
  final String description;
  final String category;
  final String icon;
  final int estimatedDurationMinutes;

  const Activity({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.estimatedDurationMinutes,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String? ?? '',
      time: json['time'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'title': title,
    'description': description,
    'category': category,
    'icon': icon,
    'estimatedDurationMinutes': estimatedDurationMinutes,
  };
}

class ItineraryDay {
  final int dayNumber;
  final String date;
  final String dayLabel;
  final List<Activity> activities;

  const ItineraryDay({
    required this.dayNumber,
    required this.date,
    required this.dayLabel,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      dayLabel: json['dayLabel'] as String? ?? '',
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'date': date,
    'dayLabel': dayLabel,
    'activities': activities.map((e) => e.toJson()).toList(),
  };
}

class Highlight {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;

  const Highlight({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
  };
}

class DestinationDetailResponse {
  final DestinationInfo destination;
  final WeatherInfo weather;
  final TravelDates travelDates;
  final BudgetInfo budget;
  final List<ItineraryDay> itinerary;
  final List<Highlight> highlights;
  final String aiInsight;
  final int matchScore;
  final bool isSaved;
  final String generatedAt;

  const DestinationDetailResponse({
    required this.destination,
    required this.weather,
    required this.travelDates,
    required this.budget,
    required this.itinerary,
    required this.highlights,
    required this.aiInsight,
    required this.matchScore,
    required this.isSaved,
    required this.generatedAt,
  });

  factory DestinationDetailResponse.fromJson(Map<String, dynamic> json) {
    return DestinationDetailResponse(
      destination: json['destination'] != null
          ? DestinationInfo.fromJson(
              json['destination'] as Map<String, dynamic>,
            )
          : DestinationInfo(
              id: '',
              name: '',
              country: '',
              fullDisplayName: '',
              heroImageUrl: '',
              galleryImageUrls: [],
              description: '',
              tags: [],
            ),
      weather: json['weather'] != null
          ? WeatherInfo.fromJson(json['weather'] as Map<String, dynamic>)
          : const WeatherInfo(
              condition: '',
              temperatureCelsius: 0,
              displayText: '',
              icon: '',
            ),
      travelDates: json['travelDates'] != null
          ? TravelDates.fromJson(json['travelDates'] as Map<String, dynamic>)
          : const TravelDates(
              startDate: '',
              endDate: '',
              displayText: '',
              durationDays: 0,
            ),
      budget: json['budget'] != null
          ? BudgetInfo.fromJson(json['budget'] as Map<String, dynamic>)
          : BudgetInfo(
              total: const BudgetAmount(
                amount: 0,
                currency: 'VND',
                displayText: 'N/A',
              ),
              breakdown: [],
            ),
      itinerary:
          (json['itinerary'] as List<dynamic>?)
              ?.map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      highlights:
          (json['highlights'] as List<dynamic>?)
              ?.map((e) => Highlight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aiInsight: json['aiInsight'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 0,
      isSaved: json['isSaved'] as bool? ?? false,
      generatedAt: json['generatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'destination': destination.toJson(),
    'weather': weather.toJson(),
    'travelDates': travelDates.toJson(),
    'budget': budget.toJson(),
    'itinerary': itinerary.map((e) => e.toJson()).toList(),
    'highlights': highlights.map((e) => e.toJson()).toList(),
    'aiInsight': aiInsight,
    'matchScore': matchScore,
    'isSaved': isSaved,
    'generatedAt': generatedAt,
  };
}
