import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:district/colors.dart';
import 'package:district/features/home/dining/dining.dart';
import 'package:district/features/home/location/locationService.dart';
import 'package:district/features/home/location/location.dart';
import 'package:district/features/home/searchpage.dart';
import 'package:district/features/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

// Riverpod provider for loading mood categories
final moodCategoriesProvider = FutureProvider<List<MoodCategory>>((ref) async {
  try {
    final String response = await rootBundle.loadString('assets/dining/mood.json');
    final data = json.decode(response);
    final categories = (data['categories'] as List)
        .map((category) => MoodCategory.fromJson(category))
        .toList();
    return categories;
  } catch (e) {
    print('Error loading mood categories: $e');
    return [];
  }
});

// Model class for mood categories
class MoodCategory {
  final String id;
  final String title;
  final String imagePath;

  MoodCategory({
    required this.id,
    required this.title,
    required this.imagePath,
  });

  factory MoodCategory.fromJson(Map<String, dynamic> json) {
    return MoodCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.stars,
      'label': 'FOR YOU',
      'color': AppColors.foryou,
    },
    {
      'icon': Icons.restaurant,
      'label': 'DINING',
      'color': AppColors.dining,
    },
    {
      'icon': Icons.confirmation_number,
      'label': 'EVENTS',
      'color': AppColors.events,
    },
    {
      'icon': Icons.movie,
      'label': 'MOVIES',
      'color': AppColors.movies,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocationProvider);
    final selectedIndex = ref.watch(selectedTabIndexProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(69),
        child: _buildCustomAppBar(context, ref, location),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildCategoryTabs(selectedIndex),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                ForYouScreen(),
                DiningScreen(),
                EventsScreen(),
                MoviesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCustomAppBar(BuildContext context, WidgetRef ref, LocationData location) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(currentLocationProvider.notifier).refreshLocation();
              },
              child: Container(
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          location.locationName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.subLocation,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Searchpage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A3E),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 12),
            AnimatedTextKit(
              animatedTexts: [
                RotateAnimatedText(
                  "Search for 'Sonu Nigam'",
                  textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                RotateAnimatedText(
                  "Search for 'Arijit Singh'",
                  textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                RotateAnimatedText(
                  "Search for 'Shreya Ghoshal'",
                  textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              repeatForever: true,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(int selectedIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _tabs.length,
          (index) => GestureDetector(
            onTap: () {
              ref.read(selectedTabIndexProvider.notifier).state = index;
            },
            child: _buildTabItem(
              icon: _tabs[index]['icon'],
              label: _tabs[index]['label'],
              color: _tabs[index]['color'],
              isSelected: selectedIndex == index,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? color : Colors.grey,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: 3,
          width: isSelected ? 40 : 0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class ForYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'For You Content',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}



class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Events Content',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class MoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Movies Content',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
