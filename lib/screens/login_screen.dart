import 'package:district/colors.dart';
import 'package:district/features/auth/verification.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final PageController _iconController = PageController(
    viewportFraction: 0.4,
    initialPage: 10000,
  );
  final PageController _textController = PageController(
    viewportFraction: 1.0,
    initialPage: 10000,
  );
  
  Timer? _autoScrollTimer;
  int _currentPage = 10000;


  final List<Map<String, dynamic>> items = [
    {
      'icon': '🎬',
      'iconColor': Color(0xFFAA66CC),  // Purple for icon
      'textColor': Color(0xFF87CEEB),  // Sky blue for text
      'label': 'Movies'
    },
    {
      'icon': '🎤',
      'iconColor': Color(0xFFAA66CC),  // Purple for icon
      'textColor': Color(0xFFFFFF00),  // Yellow for text
      'label': 'Events'
    },
    {
      'icon': '🍽️',
      'iconColor': Color(0xFFAA66CC),  // Purple for icon
      'textColor': Color(0xFFFF8A80),  // Red for text
      'label': 'Dining'
    },
  ];



  @override
  void initState() {
    super.initState();
    
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
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _currentPage++;
      
      _iconController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }


  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppColors.backgroundColor1,
              AppColors.backgrondColor2,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top,
            ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () async {
                          setState(() {
                            _isLoading = true;
                         });

                        await Future.delayed(const Duration(milliseconds: 500));
            
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Verify()),
                          );
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color.fromARGB(107, 19, 19, 19),
                         shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(50),
                         ),
                        ),
                      child: _isLoading
                         ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                          SizedBox(height: 1),
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
                
                
                    SizedBox(height: 20),
                    Spacer(),
                
                    // INFINITE CIRCULAR PAGEVIEW
                    SizedBox(
                      height: 150,
                      child: PageView.builder(
                        controller: _iconController,
                        itemBuilder: (context, index) {
                          int itemIndex = index % 3;
                          
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
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildLocationPin(
                              items[itemIndex]['icon'],
                              items[itemIndex]['iconColor'],  // Changed from 'color' to 'iconColor'
                            ),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
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
                    SizedBox(height: 10),
                    Spacer(),
                    SizedBox(
                      height: 20,
                      child: PageView.builder(
                        controller: _textController,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          int itemIndex = index % 3;
                          return _buildTextWithSparkles(
                            items[itemIndex]['label'],
                            items[itemIndex]['textColor'],  // Changed from 'color' to 'textColor'
                          );
                        },
                      ),
                    ),
                
                
                    SizedBox(height: 20),
                
                
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 19, 19, 19),
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
                          SizedBox(height: 24),
                
                
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

                          SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              Verify();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255,59,59,59),
                              minimumSize: Size(double.infinity, 56),
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

                
                
                          SizedBox(height: 24),
                
                
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[800])),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
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
                
                
                          SizedBox(height: 24),
                
                
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textcolor,
                              minimumSize: Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 12),
                                Text(
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
                
                
                          SizedBox(height: 24),
                
                
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
                                TextSpan(text: '     '),
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


  // Location Pin with original shape
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
            stops: [0.3, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Location pin shape
              CustomPaint(
                size: Size(120, 150),
                painter: LocationPinPainter(color),
              ),
              // Icon inside pin
              Positioned(
                top: 30,
                child: Text(
                  icon,
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ],
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
          SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,  // Now uses textColor from map
            ),
          ),
          SizedBox(width: 8),
          Text('✦', style: TextStyle(fontSize: 12, color: AppColors.textcolor)),
        ],
      ),
    );
  }
}


// Custom Painter for Location Pin Shape
class LocationPinPainter extends CustomPainter {
  final Color color;


  LocationPinPainter(this.color);


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.95),
          color,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;


    final path = Path();
    
    final centerX = size.width / 2;
    final coneWidth = size.width * 0.9;
    final semicircleRadius = coneWidth / 2;
    final semicircleTopY = size.height * 0.15;
    final coneTopY = semicircleTopY + semicircleRadius;
    final coneBottomY = size.height * 0.95;


    // Draw semicircle (top half of circle)
    path.addArc(
      Rect.fromCircle(
        center: Offset(centerX, coneTopY),
        radius: semicircleRadius,
      ),
      3.14159,
      3.14159,
    );


    // Draw cone triangle
    path.lineTo(centerX - semicircleRadius, coneTopY);
    path.lineTo(centerX, coneBottomY);
    path.lineTo(centerX + semicircleRadius, coneTopY);
    
    path.close();


    canvas.drawPath(path, paint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
