import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_page.dart'; // Import AuthPage

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  static const Color kBg = Colors.white;
  // ignore: unused_field
  static const Color ligthblue = Color.fromARGB(255, 106, 227, 246);
  // ignore: unused_field
  static const Color black = Color.fromRGBO(0, 0, 0, 1);

  late final AnimationController _ac;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _titleFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ac,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ac,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _buttonFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ac,
            curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _goToHome() {
    // Navigate ke Login Page dulu
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 180),
              // Title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'WARDLY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.adventPro(
                      color: Colors.lightBlueAccent,
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              FadeTransition(
                opacity: _subtitleFade,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: Text(
                    'Your Personal Wardrobe Manager',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.aBeeZee(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Get Started button
              FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _goToHome,
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.aBeeZee(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
