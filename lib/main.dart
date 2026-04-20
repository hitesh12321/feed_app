import 'dart:developer';
import 'dart:async';
import 'package:andaz/Widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  String apiUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String apiKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  await Supabase.initialize(
    url: apiUrl,
    anonKey: apiKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GPU Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PostCard(),
    );
  }
}
