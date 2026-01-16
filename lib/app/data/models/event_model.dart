import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String type; // concert, keynote, panel, etc.
  final int day; // 1, 2, 3, 4
  final DateTime startTime;
  final DateTime? endTime;
  final String venue;
  final String? imageUrl;
  final double ticketPrice; // 0 for free
  final String currency; // INR, USD
  final String? ticketPurchaseUrl;
  final int? totalSeats;
  final int? availableSeats;
  final bool isSoldOut;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.type,
    required this.day,
    required this.startTime,
    this.endTime,
    required this.venue,
    this.imageUrl,
    this.ticketPrice = 0.0,
    this.currency = 'INR',
    this.ticketPurchaseUrl,
    this.totalSeats,
    this.availableSeats,
    this.isSoldOut = false,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['eventId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      day: json['day'] as int? ?? 1,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp?)?.toDate(),
      venue: json['venue'] as String,
      imageUrl: json['imageUrl'] as String?,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      ticketPurchaseUrl: json['ticketPurchaseUrl'] as String?,
      totalSeats: json['totalSeats'] as int?,
      availableSeats: json['availableSeats'] as int?,
      isSoldOut: json['isSoldOut'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'type': type,
      'day': day,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'venue': venue,
      'imageUrl': imageUrl,
      'ticketPrice': ticketPrice,
      'currency': currency,
      'ticketPurchaseUrl': ticketPurchaseUrl,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'isSoldOut': isSoldOut,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EventModel copyWith({
    String? eventId,
    String? title,
    String? description,
    String? type,
    int? day,
    DateTime? startTime,
    DateTime? endTime,
    String?
    venue, // Explicitly handle null if needed, but here structure kept same
    String? imageUrl,
    double? ticketPrice,
    String? currency,
    String? ticketPurchaseUrl,
    int? totalSeats,
    int? availableSeats,
    bool? isSoldOut,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      currency: currency ?? this.currency,
      ticketPurchaseUrl: ticketPurchaseUrl ?? this.ticketPurchaseUrl,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
