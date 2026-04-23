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
// ScrollController for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
   // Listen to scroll events for pagination
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

     // Trigger fetchMore when scrolled within 200 pixels of the bottom
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
      backgroundColor: Colors.grey[100],
    
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Feed",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        actions: [
          IconButton(
            tooltip: "Liked Posts",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Likedpage()),
            ),
            icon: const Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).fetchInitial(),

        child: feedState.posts.isEmpty
            ?  const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "No posts yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.only(top: 8, bottom: 16),

                itemCount: feedState.posts.length + 1,

                itemBuilder: (context, index) {
                  // ── Pagination Loader ──
                  if (index == feedState.posts.length) {
                    if (feedState.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!feedState.hasMore) {
                      return Text(
                        "No more posts",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }

                  final post = feedState.posts[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    child: PostCard(
                      url: post.media_thumb_url ?? '',
                      id: post.id ?? '',
                      mobileUrl: post.media_mobile_url ?? '',
                      rawUrl: post.media_raw_url ?? '',
                      initialIsLiked: likedIds.contains(post.id),
                      initialLikeCount: post.like_count ?? 0,
                      userId: kUserId,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
