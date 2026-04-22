import 'dart:async';
import 'package:andaz/Screens/feed_screen.dart';
import 'package:andaz/Screens/sample.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  String apiUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String apiKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  await Supabase.initialize(url: apiUrl, anonKey: apiKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter GPU Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const FeedScreen(),
      ),
    );
  }
}
