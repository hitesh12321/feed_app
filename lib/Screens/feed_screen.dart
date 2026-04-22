import 'package:andaz/Providers/posts_provider.dart';
import 'package:andaz/Providers/user_provider.dart';
import 'package:andaz/Screens/LikedPage.dart';
import 'package:andaz/Widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final String kUserId = dotenv.env['USER_ID'] ?? 'User_123';
 
  // Scroll detect karne ke liye
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll end pe fetchMore() call karo
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // 200px pehle se load shuru karo
      if (currentScroll >= maxScroll - 200) {
        ref.read(feedProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
     final userLiked = ref.watch(userLikedProvider(kUserId));
    final likedIds = userLiked.asData?.value ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Likedpage()),
            ),
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      // ── Pull to Refresh ──
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).fetchInitial(),
        child: feedState.posts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: feedState.posts.length + 1, // +1 for loader
                itemBuilder: (context, index) {
                  if (index == feedState.posts.length) {
                    if (feedState.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!feedState.hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text("Sab posts dekh liye! 🎉")),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final post = feedState.posts[index];
                  return PostCard(
                    url: post.media_thumb_url ?? '',
                    id: post.id ?? '',
                    mobileUrl: post.media_mobile_url ?? '',
                    rawUrl: post.media_raw_url ?? '',
                    initialIsLiked: likedIds.contains(post.id),
                    initialLikeCount: post.like_count ?? 0,
                    userId: kUserId,
                  );
                },
              ),
      ),
    );
  }
}
