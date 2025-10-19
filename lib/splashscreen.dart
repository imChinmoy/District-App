import 'package:district/colors.dart';
import 'package:district/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}
class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.splashscreencolor, 
        child: Center(
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
            Text(
              'district',
              style: GoogleFonts.archivoBlack(
                fontSize: 46,
                color: AppColors.textcolor,
                letterSpacing: -1.5,
              ),
            ),
            SizedBox(height: 6),
            Text(
             'BY ZOMATO',
              style: GoogleFonts.montserrat(
                fontSize: 11,
               fontWeight: FontWeight.w700,
               color: AppColors.textcolor,
               letterSpacing: 3.0,
              ),
            ),
           ],
         ),
        ),
      )   
    );
  }
}