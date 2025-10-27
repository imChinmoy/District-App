import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:district/features/home/dining/dining.dart';
import 'package:district/features/home/event/event.dart';
import 'package:district/features/home/for_you/for_you.dart';
import 'package:district/features/home/location/location.dart';
import 'package:district/utils/colors.dart';
import '../home/location/locationService.dart';
import 'package:district/features/home/searchpage.dart';
import 'package:district/features/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.stars, 'label': 'FOR YOU', 'color': AppColors.foryou},
    {'icon': Icons.restaurant, 'label': 'DINING', 'color': AppColors.dining},
    {
      'icon': Icons.confirmation_number,
      'label': 'EVENTS',
      'color': AppColors.events,
    },
    {'icon': Icons.movie, 'label': 'MOVIES', 'color': AppColors.movies},
  ];

  final List<Widget> _categoryScreens = [

    const ForYouScreen(),
    const DiningScreen(),
    const EventsScreen(),
    const Center(
      child: Text(
        'Movies Content',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(69),
        child: _buildCustomAppBar(context, ref, location),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildCategoryTabs(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _categoryScreens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(
    BuildContext context,
    WidgetRef ref,
    LocationData location,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(currentLocationProvider.notifier).refreshLocation();
              },
              child: const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 24,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dining.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: Colors.black, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A3E),
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white10, width: 0.5),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: Colors.white70, size: 24),
            const SizedBox(width: 12),

            AnimatedTextKit(
              animatedTexts: [
                RotateAnimatedText(
                  "Search for 'The Great Indian Kitchen'",
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                RotateAnimatedText(
                  "Search for 'Live Concerts'",
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                RotateAnimatedText(
                  "Search for 'Inception'",
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              repeatForever: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _tabs.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: _buildTabItem(
              icon: _tabs[index]['icon'],
              label: _tabs[index]['label'],
              color: _tabs[index]['color'],
              isSelected: _selectedIndex == index,
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
        Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
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
          duration: const Duration(milliseconds: 200),
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
