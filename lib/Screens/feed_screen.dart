import 'package:andaz/Providers/posts_provider.dart';
import 'package:andaz/Screens/LikedPage.dart';
import 'package:andaz/Widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    // final provider = ref.watch(feedProvider );
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed App"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Likedpage()),
              );
            },
            child: Icon(Icons.favorite),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final provider = ref.watch(feedProvider);
          return provider.when(
            data: (value) => ListView.builder(
              itemBuilder: (context, index) => PostCard(
                // likeCount: value[index].likeCount,
                // isLiked: value[index].isLiked,
                url: value[index].media_mobile_url ?? '',
                id: value[index].id ?? '',
              ),
              itemCount: value.length,
            ),
            error: (error, stack) => Text(error.toString()),
            loading: () => Center(child: const CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
