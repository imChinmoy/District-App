import 'package:district/models/Review_model.dart';
import 'package:district/models/dining/menu_model.dart';

class DiningModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phoneNumber;
  final String email;
  final String description;
  final List<String> images; 
  final List<MenuModel> menu; 
  final List<String> facilities; // e.g. ["WiFi", "Parking", "Outdoor Seating"]
  final double rating;
  final int totalReviews;
  final List<ReviewModel> reviews;
  bool isOpen=false;
  final String openingTime;
  final String closingTime;
  final double averageCostForTwo;

  DiningModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phoneNumber,
    required this.email,
    required this.description,
    required this.images,
    required this.menu,
    required this.facilities,
    required this.rating,
    required this.totalReviews,
    required this.reviews,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.averageCostForTwo,
  });

  factory DiningModel .fromMap(Map<String, dynamic> map) {
    return DiningModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      pincode: map['pincode'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      description: map['description'],
      images: List<String>.from(map['images']),
      menu: List<MenuModel>.from(map['menu'].map((item) => MenuModel.fromMap(item))),
      facilities: List<String>.from(map['facilities']),
      rating: map['rating'].toDouble(),
      totalReviews: map['totalReviews'],
      reviews: List<ReviewModel>.from(map['reviews'].map((review) => ReviewModel.fromMap(review))),
      isOpen: map['isOpen'],
      openingTime: map['openingTime'],
      closingTime: map['closingTime'],
      averageCostForTwo: map['averageCostForTwo'].toDouble(),    
    );    
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phoneNumber': phoneNumber,
      'email': email,
      'description': description,
      'images': images,
      'menu': menu.map((item) => item.toMap()).toList(),
      'facilities': facilities,
      'rating': rating,
      'totalReviews': totalReviews,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'isOpen': isOpen,
      'openingTime': openingTime,
      'closingTime': closingTime,     
      'averageCostForTwo': averageCostForTwo,
    };    
  }

}
