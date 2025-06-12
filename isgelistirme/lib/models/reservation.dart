enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class Reservation {
  final String id;
  final String businessId;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final String time;
  final int partySize;
  final ReservationStatus status;
  final String notes;

  const Reservation({
    required this.id,
    required this.businessId,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.time,
    required this.partySize,
    required this.status,
    this.notes = '',
  });

  Reservation copyWith({
    String? id,
    String? businessId,
    String? customerName,
    String? customerPhone,
    DateTime? date,
    String? time,
    int? partySize,
    ReservationStatus? status,
    String? notes,
  }) {
    return Reservation(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      date: date ?? this.date,
      time: time ?? this.time,
      partySize: partySize ?? this.partySize,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'date': date.toIso8601String(),
      'time': time,
      'partySize': partySize,
      'status': status.toString(),
      'notes': notes,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      partySize: json['partySize'] as int,
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      notes: json['notes'] ?? '',
    );
  }
}
