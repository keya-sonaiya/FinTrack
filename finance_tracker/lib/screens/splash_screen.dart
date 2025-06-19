import 'package:flutter/material.dart';
import 'auth_screen.dart'; // <-- Make sure this is created and imported
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
@override
void initState() {
  super.initState();

  Future.delayed(const Duration(seconds: 3), () {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // User is logged in, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Create this
      );
    } else {
      // Not logged in, go to AuthScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'FinTrack',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 1, 87, 4),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 25),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 1, 87, 4),
            ),
          ],
        ),
      ),
    );
  }
}