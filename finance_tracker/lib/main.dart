import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fmlhdfgowcoqphwbboys.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtbGhkZmdvd2NvcXBod2Jib3lzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4OTYyNDUsImV4cCI6MjA2NTQ3MjI0NX0.kXR4KdCkr_g_Es3lmMOod45HNYJT34sKgvntSgiTmao',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Finance Tracker',
          theme: ThemeData(
            fontFamily: 'Poppins',
            brightness: Brightness.light,
            primarySwatch: Colors.green,
          ),
          darkTheme: ThemeData(
  fontFamily: 'Poppins',
  brightness: Brightness.dark,
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[900],
    labelStyle: const TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
    ),
    prefixIconColor: Colors.white,
    suffixIconColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
  ),
),

          themeMode: mode,
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}