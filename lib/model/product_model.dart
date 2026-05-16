import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    required this.scentFamily,
    required this.overlay,
  });

  final String id;
  final String title;
  final String brand;
  final double price;
  final String image;
  final String description;
  final String category;
  final String scentFamily;
  final Color overlay;

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  Product copyWith({
    String? id,
    String? title,
    String? brand,
    double? price,
    String? image,
    String? description,
    String? category,
    String? scentFamily,
    Color? overlay,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
      scentFamily: scentFamily ?? this.scentFamily,
      overlay: overlay ?? this.overlay,
    );
  }
}
