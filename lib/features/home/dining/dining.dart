import 'dart:convert';
import 'package:district/utils/colors.dart';
import 'package:district/features/home/dining/rest.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoodCategory {
  final String id;
  final String title;
  final String imagePath;

  MoodCategory({
    required this.id,
    required this.title,
    required this.imagePath,
  });

  factory MoodCategory.fromJson(Map<String, dynamic> json) => MoodCategory(
        id: json['id'] as String,
        title: json['title'] as String,
        imagePath: json['imagePath'] as String,
      );
}

final moodCategoriesProvider = FutureProvider<List<MoodCategory>>((ref) async {
  final response = await rootBundle.loadString('assets/dining/mood.json');
  final data = json.decode(response);
  return (data['categories'] as List)
      .map((category) => MoodCategory.fromJson(category))
      .toList();
});

final restaurantsProvider = FutureProvider<List<DiningModel>>((ref) async {
  final response =
      await rootBundle.loadString('assets/restaurant/restaurants.json');
  final data = json.decode(response);
  return (data['restaurants'] as List)
      .map((r) => DiningModel.fromMap(r))
      .toList();
});

class DiningScreen extends ConsumerWidget {
  const DiningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodCategoriesAsync = ref.watch(moodCategoriesProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionHeading('IN THE MOOD FOR'),
            const SizedBox(height: 24),
            _buildMoodSection(moodCategoriesAsync),
            const SizedBox(height: 40),
            _buildSectionHeading('ALL RESTAURANTS'),
            const SizedBox(height: 24),
            _buildRestaurantsSection(context, restaurantsAsync),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildDivider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
          ),
          Expanded(child: _buildDivider(reverse: true)),
        ],
      ),
    );
  }

  Widget _buildDivider({bool reverse = false}) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            reverse ? Colors.grey.withOpacity(0.5) : Colors.transparent,
            reverse ? Colors.transparent : Colors.grey.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection(AsyncValue<List<MoodCategory>> asyncData) {
    return asyncData.when(
      data: (categories) => categories.isEmpty
          ? _buildMessage('No categories available')
          : _buildMoodCards(categories),
      loading: () => _buildMessage('Loading...', isLoading: true),
      error: (e, _) => _buildMessage('Error: $e', isError: true),
    );
  }

  Widget _buildRestaurantsSection(
      BuildContext context, AsyncValue<List<DiningModel>> asyncData) {
    return asyncData.when(
      data: (restaurants) => restaurants.isEmpty
          ? _buildMessage('No restaurants available')
          : _buildRestaurantsList(context, restaurants),
      loading: () => _buildMessage('Loading restaurants...', isLoading: true),
      error: (e, _) =>
          _buildMessage('Error loading restaurants: $e', isError: true),
    );
  }

  Widget _buildMessage(String message,
      {bool isLoading = false, bool isError = false}) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(color: AppColors.dining),
            if (isError)
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: isLoading || isError ? 16 : 0),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCards(List<MoodCategory> categories) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        cacheExtent: 500,
        itemBuilder: (context, index) => _buildMoodCard(categories[index]),
      ),
    );
  }

  Widget _buildRestaurantsList(
      BuildContext context, List<DiningModel> restaurants) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) => RestaurantCard(
        restaurant: restaurants[index],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailPage(
                restaurant: restaurants[index],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodCard(MoodCategory category) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              category.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.restaurant,
                    color: Colors.white54, size: 48),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  category.title.replaceAll('\\n', '\n'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final DiningModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    restaurant.images.isNotEmpty
                        ? restaurant.images[0]
                        : 'assets/restaurant/dining.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.restaurant,
                          color: Colors.white54, size: 60),
                    ),
                  ),
                ),
                if (restaurant.averageCostForTwo < 1000)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.local_offer,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Flat 20% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.bookmark_border,
                          color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.star,
                                color: Colors.white, size: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'North Indian • ₹${restaurant.averageCostForTwo.toInt()} for two',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_calculateDistance()} km • ${restaurant.address}, ${restaurant.city}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDistance() {
    return (1.0 + (restaurant.id.hashCode % 50) / 10);
  }
}
