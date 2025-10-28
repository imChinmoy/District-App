import 'package:district/utils/colors.dart';
import 'package:district/features/home/home_screen.dart';
import 'package:district/features/auth/verification.dart';
import 'package:district/providers/auth_provider.dart'; // <-- make sure this path is correct
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

final iconControllerProvider = Provider<PageController>((ref) {
  return PageController(viewportFraction: 0.4, initialPage: 10000);
});

final textControllerProvider = Provider<PageController>((ref) {
  return PageController(viewportFraction: 1.0, initialPage: 10000);
});

final currentPageProvider = StateProvider<int>((ref) => 10000);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  final List<Map<String, dynamic>> items = const [
    {
      'icon': '🎤',
      'iconColor': Color(0xFFAA66CC),
      'textColor': Color(0xFFFFFF00),
      'label': 'Events',
    },
    {
      'icon': '🍽️',
      'iconColor': Color(0xFFAA66CC),
      'textColor': Color(0xFFFF8A80),
      'label': 'Dining',
    },
    {
      'icon': '🎬',
      'iconColor': Color(0xFFAA66CC),
      'textColor': Color(0xFF87CEEB),
      'label': 'Movies',
    },
    {
      'icon': '🏏',
      'iconColor': Color(0xFFAA66CC),
      'textColor': Color(0xFFFFFF00),
      'label': 'Sports',
    },
    {
      'icon': '🍴',
      'iconColor': Color(0xFFAA66CC),
      'textColor': Color(0xFFFF8A80),
      'label': 'Food',
    },
  ];

  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    ref.watch(iconControllerProvider);
    final textController = ref.watch(textControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [AppColors.backgroundColor1, AppColors.backgrondColor2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                           ref.read(isLoadingProvider.notifier).state = true;
                           await Future.delayed(const Duration(milliseconds: 500));
                           if (context.mounted) {
                            context.go('/guest');
                           }
                           ref.read(isLoadingProvider.notifier).state = false;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              107,
                              19,
                              19,
                              19,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey[700],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'district',
                            style: GoogleFonts.archivoBlack(
                              fontSize: 30,
                              color: AppColors.textcolor,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'BY ZOMATO',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textcolor,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    AutoScrollPageView(items: items),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'One app for all your going out plans',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textcolor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Spacer(),
                    SizedBox(
                      height: 20,
                      child: PageView.builder(
                        controller: textController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          int itemIndex = index % items.length;
                          return _buildTextWithSparkles(
                            items[itemIndex]['label'],
                            items[itemIndex]['textColor'],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 19, 19, 19),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Log in or sign up',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textcolor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textcolor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your mail id',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[800]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[800]!,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Verify(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                59,
                                59,
                                59,
                              ),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[800])),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[800])),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _signInWithGoogle(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textcolor,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Login with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text.rich(
                            TextSpan(
                              text: 'By continuing, you agree to our\n',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Services',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AppColors.textcolor,
                                  ),
                                ),
                                const TextSpan(text: '     '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AppColors.textcolor,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextWithSparkles(String title, Color color) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✦', style: TextStyle(fontSize: 12, color: AppColors.textcolor)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text('✦', style: TextStyle(fontSize: 12, color: AppColors.textcolor)),
        ],
      ),
    );
  }
}

// ================= AUTO SCROLL COMPONENT =================
class AutoScrollPageView extends ConsumerStatefulWidget {
  const AutoScrollPageView({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  ConsumerState<AutoScrollPageView> createState() => _AutoScrollPageViewState();
}

class _AutoScrollPageViewState extends ConsumerState<AutoScrollPageView> {
  Timer? _autoScrollTimer;
  late PageController _iconController;
  late PageController _textController;

  @override
  void initState() {
    super.initState();
    _iconController = ref.read(iconControllerProvider);
    _textController = ref.read(textControllerProvider);

    _iconController.addListener(() {
      if (_iconController.position.haveDimensions) {
        final page = _iconController.page ?? 10000;
        if (_textController.hasClients) {
          _textController.jumpToPage(page.round());
        }
      }
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final notifier = ref.read(currentPageProvider.notifier);
      notifier.state++;
      _iconController.animateToPage(
        notifier.state,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _iconController,
        itemBuilder: (context, index) {
          int itemIndex = index % widget.items.length;
          return AnimatedBuilder(
            animation: _iconController,
            builder: (context, child) {
              double value = 1.0;
              if (_iconController.position.haveDimensions) {
                value = _iconController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
              }
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildLocationPin(
              widget.items[itemIndex]['icon'],
              widget.items[itemIndex]['iconColor'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationPin(String icon, Color color) {
    return Center(
      child: Container(
        width: 200,
        height: 240,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.6),
              color.withOpacity(0.3),
              Colors.transparent,
            ],
            stops: const [0.3, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 150),
                painter: LocationPinPainter(color),
              ),
              Positioned(
                top: 30,
                child: Text(icon, style: const TextStyle(fontSize: 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPinPainter extends CustomPainter {
  final Color color;
  LocationPinPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.95), color],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final coneWidth = size.width * 0.9;
    final semicircleRadius = coneWidth / 2;
    final semicircleTopY = size.height * 0.15;
    final coneTopY = semicircleTopY + semicircleRadius;
    final coneBottomY = size.height * 0.95;

    path.addArc(
      Rect.fromCircle(
        center: Offset(centerX, coneTopY),
        radius: semicircleRadius,
      ),
      3.14159,
      3.14159,
    );

    path.lineTo(centerX - semicircleRadius, coneTopY);
    path.lineTo(centerX, coneBottomY);
    path.lineTo(centerX + semicircleRadius, coneTopY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
