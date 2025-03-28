import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_screen.dart';
import 'pages/welcome_screen.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/home_screen.dart'; // Import HomeScreen
import 'pages/products_screen.dart'; // Import ProductsScreen
import 'pages/map_screen.dart'; // Import MapScreen
import 'pages/marketplace_screen.dart'; // Import MarketplaceScreen
import 'pages/exhibitors_screen.dart'; // Import ExhibitorsScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyA6Y1jSfpg0FMUQPlUBmok6UUy6pe-49P0",
    projectId: "agric-mis",
    messagingSenderId: "677442321518",
    appId: "1:677442321518:web:2209336e8a38224cfb3a7f",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        ProductsScreen.id: (context) => const ProductsScreen(),
        MapScreen.id: (context) => const MapScreen(),
        MarketplaceScreen.id: (context) => const MarketplaceScreen(),
        ExhibitorsScreen.id: (context) => const ExhibitorsScreen(),
      },
    );
  }
}
