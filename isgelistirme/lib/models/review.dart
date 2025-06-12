class Review {
  final String id;
  final String businessId;
  final String userName;
  final String comment;
  final int rating;
  final DateTime date;
  final String? response;
  final DateTime? responseDate;

  const Review({
    required this.id,
    required this.businessId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
    this.response,
    this.responseDate,
  });

  Review copyWith({
    String? id,
    String? businessId,
    String? userName,
    String? comment,
    int? rating,
    DateTime? date,
    String? response,
    DateTime? responseDate,
  }) {
    return Review(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      response: response ?? this.response,
      responseDate: responseDate ?? this.responseDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
      'response': response,
      'responseDate': responseDate?.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userName: json['userName'] as String,
      comment: json['comment'] as String,
      rating: json['rating'] as int,
      date: DateTime.parse(json['date'] as String),
      response: json['response'] as String?,
      responseDate: json['responseDate'] != null
          ? DateTime.parse(json['responseDate'] as String)
          : null,
    );
  }
}
