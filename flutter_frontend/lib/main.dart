import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_page.dart';
import 'screens/home_page.dart';
import 'screens/capture_page.dart';
import 'screens/all_time_tracker_page.dart';
import 'screens/meal_detail_page.dart';
import 'services/use_auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => UseAuth(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<UseAuth>(context);

    return MaterialApp(
      title: 'Food App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: auth.loading
          ? const Center(child: CircularProgressIndicator())
          : auth.user == null
              ? const AuthPage()
              : const HomePage(),
      routes: {
        '/auth': (context) => const AuthPage(),
        '/capture': (context) => const CapturePage(),
        '/tracker': (context) => const AllTimeTrackerPage(),
        '/meal': (context) => const MealDetailPage(),
      },
    );
  }
}