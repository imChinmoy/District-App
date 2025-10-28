import 'package:district/utils/colors.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/mood_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:district/features/controllers/program_controller.dart'; 
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';



typedef FallbackImageBuilder = Widget Function();

final diningHomeDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final diningFuture = ref.watch(diningProvider.future);
  final moodFuture = ref.watch(diningTypeProvider.future);

  final results = await Future.wait([diningFuture, moodFuture]);

  return {
    'diningList': results[0] as List<DiningModel>,
    'moodCategories': results[1] as List<MoodCategory>,
  };
});

class DiningScreen extends ConsumerWidget {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final diningHomeDataAsync = ref.watch(diningHomeDataProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(diningHomeDataProvider.future),
        child: diningHomeDataAsync.when(
          data: (data) {
            final diningList = data['diningList'] as List<DiningModel>;
            final moodCategories = data['moodCategories'] as List<MoodCategory>;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const _SectionHeading('IN THE MOOD FOR'),
                  const SizedBox(height: 24),
                  moodCategories.isEmpty
                      ? const _MessageWidget(message: 'No categories found.')
                      : _MoodSection(categories: moodCategories),
                  const SizedBox(height: 40),
                  const _SectionHeading('ALL RESTAURANTS'),
                  const SizedBox(height: 24),
                  diningList.isEmpty
                      ? const _MessageWidget(message: 'No restaurants found.')
                      : _RestaurantsSection(restaurants: diningList),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: _MessageWidget(message: 'Loading...', isLoading: true)),
          error: (e, stack) => Center(
            child: _MessageWidget(message: 'Error loading data: $e', isError: true),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

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

  @override
  Widget build(BuildContext context) {
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
}

class _MoodSection extends StatelessWidget {
  final List<MoodCategory> categories;

  const _MoodSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) => _MoodCard(category: categories[index]),
      ),
    );
  }
}

class _MoodSectionSkeleton extends StatelessWidget {
  const _MoodSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade900,
        highlightColor: Colors.grey.shade800,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final MoodCategory category;
  const _MoodCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ImageLoader(imageUrl: category.imageUrl, height: 200),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
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
      ),
    );
  }
}

class _RestaurantsSection extends StatelessWidget {
  final List<DiningModel> restaurants;
  const _RestaurantsSection({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: restaurants.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: () {
            context.push('/home/dining/detail', extra: restaurant);
          },
        );
      },
    );
  }
}

class _RestaurantsSectionSkeleton extends StatelessWidget {
  const _RestaurantsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final FallbackImageBuilder fallbackImage;

  const _ImageLoader({
    required this.imageUrl,
    this.height = 200,
    this.fallbackImage = _defaultFallbackImage,
  });

  static Widget _defaultFallbackImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey.shade800,
      child: const Icon(Icons.restaurant, color: Colors.white54, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return fallbackImage();
    }

    final ImageProvider imageProvider = imageUrl!.startsWith('http')
        ? NetworkImage(imageUrl!)
        : AssetImage(imageUrl!);

    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => fallbackImage(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade800,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.dining),
          ),
        );
      },
    );
  }
}

class _MessageWidget extends StatelessWidget {
  final String message;
  final bool isLoading;
  final bool isError;

  const _MessageWidget({
    required this.message,
    this.isLoading = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
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
}

class RestaurantCard extends StatelessWidget {
  final DiningModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  double _calculateDistance() {
    return (1.0 + (restaurant.id.hashCode % 50) / 10);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: _ImageLoader(
                    imageUrl: restaurant.images.isNotEmpty
                        ? restaurant.images[0]
                        : 'assets/restaurant/dining.png',
                    height: 200,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                if (restaurant.averageCostForTwo < 1000)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[700],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.local_offer,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '20% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
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
                      const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF388E3C),
                          borderRadius: BorderRadius.circular(4),
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
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '₹${restaurant.averageCostForTwo.toInt()} for two',
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_calculateDistance()} km • ${restaurant.address}, ${restaurant.city}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}