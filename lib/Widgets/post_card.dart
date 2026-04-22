import 'package:andaz/Providers/like_provider.dart';
import 'package:andaz/Screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostCard extends ConsumerWidget {
  // ← StatelessWidget se ConsumerWidget
  final String url;
  final String id;
  final String mobileUrl;    
  final String rawUrl; 
  final bool initialIsLiked;
  final int initialLikeCount;
  final String userId;

  const PostCard({
    required this.url,
    required this.id,
    required this.mobileUrl,
    required this.rawUrl,
    required this.initialIsLiked,
    required this.initialLikeCount,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = {
      'postId': id,
      'userId': userId,
      'initialIsLiked': initialIsLiked,
      'initialLikeCount': initialLikeCount,
    };

    final likeState = ref.watch(likeProvider(params));
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
              Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailScreen(
        id: id,
        thumbUrl: url,           // jo abhi dikh raha hai
        mobileUrl: mobileUrl,    // 1080p
        rawUrl: rawUrl,          // download ke liye
      ),
    ),
  );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                // here i am using this hero widget which makes my image to show as a zoom animation on differet screen
                // and i am using the id as the tag for hero widget which is unique for each post and it will match with the tag in the detail view to show the animation
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: id,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.network(
                          url,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 600, // RAM bachao
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ── Like Button + Count ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Like Count
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '${likeState.likeCount}',
                              key: ValueKey(
                                likeState.likeCount,
                              ), // animation ke liye
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: likeState.isLiked
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Heart Button
                          GestureDetector(
                            onTap: () => ref
                                .read(likeProvider(params).notifier)
                                .toggleLike(context),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                              child: Icon(
                                likeState.isLiked
                                    ? Icons
                                          .favorite // filled red
                                    : Icons.favorite_border, // empty grey
                                key: ValueKey(likeState.isLiked),
                                color: likeState.isLiked
                                    ? Colors.red
                                    : Colors.grey,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
