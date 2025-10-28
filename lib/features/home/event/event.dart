import 'package:district/features/controllers/program_controller.dart';
import 'package:district/features/home/event/categoryevent.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

typedef FallbackImageBuilder = Widget Function();

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(eventProvider.future),
      ref.read(artistProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventProvider);
    final artistsAsync = ref.watch(artistProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: AppColors.events,
        onRefresh: () async {
          ref.invalidate(eventProvider);
          ref.invalidate(artistProvider);
          await _loadData();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                const _SectionHeading('🔥 FEATURED EVENTS'),
                const SizedBox(height: 20),
                _EventListSection(asyncData: eventsAsync, isHorizontal: true),
                const SizedBox(height: 32),
                const _SectionHeading('🎤 ARTISTS IN YOUR DISTRICT'),
                const SizedBox(height: 20),
                _ArtistSection(artistsAsync: artistsAsync),
                const SizedBox(height: 32),
                const _SectionHeading('🌎 EXPLORE CATEGORIES'),
                const SizedBox(height: 20),
                const _ExploreCategoriesGrid(),
                const SizedBox(height: 32),
                const _SectionHeading('🗓️ ALL UPCOMING EVENTS'),
                const SizedBox(height: 20),
                _EventListSection(asyncData: eventsAsync, isHorizontal: false),
                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textcolor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
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
            if (isLoading) CircularProgressIndicator(color: AppColors.events),
            if (isError)
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            SizedBox(height: isLoading || isError ? 12 : 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final FallbackImageBuilder fallbackImage;

  const _ImageLoader({
    required this.imageUrl,
    required this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.fallbackImage = _defaultFallbackImage,
  });

  static Widget _defaultFallbackImage() {
    return Container(
      color: AppColors.cardBackground,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white30,
          size: 40,
        ),
      ),
    );
  }

  static Widget _debugFallbackImage(String? path) {
    return Container(
      color: Colors.red.shade900,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          'Image Failed\nPath: ${path ?? "null"}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox(height: height, width: width, child: fallbackImage());
    }

    final String path = imageUrl!;
    final bool isNetwork = path.startsWith('http');

    final ImageProvider imageProvider = isNetwork
        ? NetworkImage(path)
        : AssetImage(path);

    return Image(
      image: imageProvider,
      fit: fit,
      height: height,
      width: width,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: height,
          width: width,
          child: _debugFallbackImage(path),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: AppColors.cardBackground,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.events,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}

class _EventListSection extends StatelessWidget {
  final AsyncValue<List<EventModel>> asyncData;
  final bool isHorizontal;

  const _EventListSection({
    required this.asyncData,
    required this.isHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      data: (events) => events.isEmpty
          ? const _MessageWidget(message: 'No events available')
          : isHorizontal
              ? _buildHorizontalList(context, events)
              : _buildVerticalList(context, events),
      loading: () => const _MessageWidget(
        message: 'Fetching events... ⏳',
        isLoading: true,
      ),
      error: (e, _) => const _MessageWidget(
        message: 'Failed to load events. Please check your connection.',
        isError: true,
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<EventModel> events) {
    return SizedBox(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) => HorizontalEventCard(
          event: events[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: events[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList(BuildContext context, List<EventModel> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) => VerticalEventCard(
        event: events[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: events[index]),
          ),
        ),
      ),
    );
  }
}

class _ArtistSection extends StatelessWidget {
  final AsyncValue<List<ArtistModel>> artistsAsync;

  const _ArtistSection({required this.artistsAsync});

  @override
  Widget build(BuildContext context) {
    return artistsAsync.when(
      data: (artists) => artists.isEmpty
          ? const _MessageWidget(message: 'No featured artists right now.')
          : SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: artists.length,
                itemBuilder: (context, index) =>
                    ArtistCard(artist: artists[index]),
              ),
            ),
      loading: () =>
          const _MessageWidget(message: 'Loading artists...', isLoading: true),
      error: (e, _) => const _MessageWidget(
        message: 'Failed to load artists.',
        isError: true,
      ),
    );
  }
}

class _ExploreCategoriesGrid extends StatelessWidget {
  const _ExploreCategoriesGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
        children: const [
          _CategoryCard(
            title: 'MUSIC',
            category: EventCategory.concert,
            emoji: '🎸',
            color: AppColors.categoryMusic,
          ),
          _CategoryCard(
            title: 'NIGHTLIFE',
            category: null,
            emoji: '🪩',
            color: AppColors.categoryNightlife,
          ),
          _CategoryCard(
            title: 'COMEDY',
            category: EventCategory.standup,
            emoji: '🎤',
            color: AppColors.categoryComedy,
          ),
          _CategoryCard(
            title: 'SPORTS',
            category: null,
            emoji: '🏟️',
            color: AppColors.categorySports,
          ),
          _CategoryCard(
            title: 'PERFORMANCES',
            category: EventCategory.exhibition,
            emoji: '🎭',
            color: AppColors.categoryPerformances,
          ),
          _CategoryCard(
            title: 'FESTIVALS',
            category: EventCategory.festival,
            emoji: '🥂',
            color: AppColors.categoryFestivals,
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final EventCategory? category;
  final String emoji;
  final Color color;

  const _CategoryCard({
    required this.title,
    this.category,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (category != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryEventsPage(category: category!, categoryName: title),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayDark,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerticalEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const VerticalEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = event.images.isNotEmpty ? event.images[0] : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayDark,
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
                  child: _ImageLoader(imageUrl: imagePath, height: 180),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.overlayDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.eventsOverlay,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      event.category.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
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
                  Text(
                    DateFormat(
                      'EEEE, MMM dd',
                    ).format(event.startDate).toUpperCase(),
                    style: TextStyle(
                      color: AppColors.eventsHighlight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.price == 0
                              ? 'FREE'
                              : '₹${event.price.toInt()} ONWARDS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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

class ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: _ImageLoader(
              imageUrl: artist.imageUrl,
              height: 120,
              width: 120,
              fallbackImage: () => Container(
                height: 120,
                width: 120,
                color: AppColors.cardBorder,
                child: const Icon(Icons.person, color: Colors.white, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              artist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            artist.category,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class HorizontalEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const HorizontalEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = event.images.isNotEmpty ? event.images[0] : null;
    final themeColor = AppColors.events;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayDark,
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    top: Radius.circular(16),
                  ),
                  child: _ImageLoader(
                    imageUrl: imagePath,
                    height: 220,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.overlayDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.eventsOverlay,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      event.category.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
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
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEE, dd MMM @ h:mm a').format(event.startDate),
                    style: TextStyle(
                      color: AppColors.eventsHighlight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.secondaryText,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.price == 0
                              ? 'FREE'
                              : '₹${event.price.toInt()} ONWARDS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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