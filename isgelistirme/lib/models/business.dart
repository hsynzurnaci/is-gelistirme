import 'review.dart';

class Business {
  final String id;
  final String name;
  final String address;
  final String description;
  final double rating;
  final String category;
  final List<String> documents;
  final String? photoUrl;
  final bool isFavorite;
  final double? monthlyIncome;
  final List<MenuItem> menu;
  final List<Reservation> reservations;
  final List<Review> reviews;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  const Business({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.rating,
    required this.category,
    required this.documents,
    this.photoUrl,
    this.isFavorite = false,
    this.monthlyIncome,
    this.menu = const [],
    this.reservations = const [],
    this.reviews = const [],
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  Business copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    double? rating,
    String? category,
    List<String>? documents,
    String? photoUrl,
    bool? isFavorite,
    double? monthlyIncome,
    List<MenuItem>? menu,
    List<Reservation>? reservations,
    List<Review>? reviews,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      documents: documents ?? this.documents,
      photoUrl: photoUrl ?? this.photoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      menu: menu ?? this.menu,
      reservations: reservations ?? this.reservations,
      reviews: reviews ?? this.reviews,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'documents': documents,
      'rating': rating,
      'photoUrl': photoUrl,
      'isFavorite': isFavorite,
      'category': category,
      'monthlyIncome': monthlyIncome,
      'menu': menu.map((m) => m.toJson()).toList(),
      'reservations': reservations.map((r) => r.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      category: json['category'] as String,
      documents: List<String>.from(json['documents'] as List),
      photoUrl: json['photoUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      monthlyIncome: json['monthlyIncome'] as double?,
      menu: (json['menu'] as List?)
              ?.map((m) => MenuItem.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      reservations: (json['reservations'] as List?)
              ?.map((r) => Reservation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}

class Reservation {
  final String id;
  final String customerName;
  final String customerPhone;
  final DateTime dateTime;
  final int numberOfGuests;
  final String? notes;
  final ReservationStatus status;

  Reservation({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.dateTime,
    required this.numberOfGuests,
    this.notes,
    this.status = ReservationStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'dateTime': dateTime.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'notes': notes,
      'status': status.toString().split('.').last,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      numberOfGuests: json['numberOfGuests'] as int,
      notes: json['notes'] as String?,
      status: ReservationStatus.values[json['status'] as int],
    );
  }
}

enum ReservationStatus { pending, confirmed, cancelled, completed }
