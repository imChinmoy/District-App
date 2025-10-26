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
  final List<String> facilities; 
  final double rating;
  final int totalReviews;
  final List<ReviewModel> reviews;
  final bool isOpen;
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

  factory DiningModel.fromMap(Map<String, dynamic> map) {
    List<T> _safeMapList<T>(dynamic list, T Function(Map<String, dynamic>) fromMap) {
      if (list == null) return <T>[];
      return (list as List<dynamic>).map((item) => fromMap(item as Map<String, dynamic>)).toList();
    }
    
    List<String> _safeCastStringList(dynamic list) { 
      if (list == null) return <String>[];
      return (list as List<dynamic>).map((e) => e.toString()).toList();
    }
    
    return DiningModel(
      
      id: map['id'] as String? ?? 'UNKNOWN_ID',
      name: map['name'] as String? ?? 'Unnamed Restaurant',
      address: map['address'] as String? ?? 'N/A',
      city: map['city'] as String? ?? 'N/A',
      state: map['state'] as String? ?? 'N/A',
      pincode: map['pincode'] as String? ?? 'N/A',
      phoneNumber: map['phoneNumber'] as String? ?? 'N/A',
      email: map['email'] as String? ?? 'N/A',
      description: map['description'] as String? ?? 'No description available.',
      images: _safeCastStringList(map['images']), 
      menu: _safeMapList<MenuModel>(map['menu'], MenuModel.fromMap),
      facilities: _safeCastStringList(map['facilities']),
      rating: (map['rating'] as num? ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] as int? ?? 0,
      reviews: _safeMapList<ReviewModel>(map['reviews'], ReviewModel.fromMap),
      isOpen: map['isOpen'] as bool? ?? false,
      openingTime: map['openingTime'] as String? ?? 'Closed',
      closingTime: map['closingTime'] as String? ?? 'Closed',
      averageCostForTwo: (map['averageCostForTwo'] as num? ?? 0.0).toDouble(),
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