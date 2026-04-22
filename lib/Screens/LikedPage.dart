import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Likedpage extends ConsumerStatefulWidget {
  const Likedpage({super.key});

  @override
  ConsumerState<Likedpage> createState() => _LikedpageState();
}

class _LikedpageState extends ConsumerState<Likedpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("liked")));
  }
}
