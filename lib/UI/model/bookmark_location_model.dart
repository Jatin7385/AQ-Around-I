import 'package:flutter/material.dart';

class BookmarkedLocation {
  final String id;
  final String name;
  final String address;
  final int currentCigarettesConsumed;
  final DateTime bookmarkedAt;

  BookmarkedLocation({
    required this.id,
    required this.name,
    required this.address,
    this.currentCigarettesConsumed = 0,
    DateTime? bookmarkedAt,
  }) : bookmarkedAt = bookmarkedAt ?? DateTime.now();

  // Method to update cigarette count
  BookmarkedLocation copyWith({
    String? id,
    String? name,
    String? address,
    int? currentCigarettesConsumed,
    DateTime? bookmarkedAt,
  }) {
    return BookmarkedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      currentCigarettesConsumed: currentCigarettesConsumed ?? this.currentCigarettesConsumed,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
    );
  }
}