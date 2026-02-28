class BudgetAmount {
  final int amount;
  final String currency;
  final String displayText;

  const BudgetAmount({
    required this.amount,
    required this.currency,
    required this.displayText,
  });

  factory BudgetAmount.fromJson(Map<String, dynamic> json) {
    return BudgetAmount(
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
      displayText: json['displayText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'displayText': displayText,
  };
}

class UserPreferences {
  final String originLocation;
  final int durationDays;
  final BudgetAmount budget;
  final List<String> travelStyle;
  final String departureDate;

  const UserPreferences({
    required this.originLocation,
    required this.durationDays,
    required this.budget,
    required this.travelStyle,
    required this.departureDate,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      originLocation: json['originLocation'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      budget: json['budget'] != null
          ? BudgetAmount.fromJson(json['budget'] as Map<String, dynamic>)
          : const BudgetAmount(amount: 0, currency: 'VND', displayText: 'N/A'),
      travelStyle:
          (json['travelStyle'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      departureDate: json['departureDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'originLocation': originLocation,
    'durationDays': durationDays,
    'budget': budget.toJson(),
    'travelStyle': travelStyle,
    'departureDate': departureDate,
  };
}
