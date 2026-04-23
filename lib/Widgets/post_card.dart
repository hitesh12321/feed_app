import 'package:andaz/Providers/like_provider.dart';
import 'package:andaz/Screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostCard extends ConsumerWidget {
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
    final params = (
      id,
      userId,
      initialIsLiked,
      initialLikeCount,
    ); // ✅ Record, not Map

    final likeState = ref.watch(likeProvider(params));

    final screenWidth = MediaQuery.of(context).size.width;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheW = (screenWidth * dpr).toInt();

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      id: id,
                      thumbUrl: url,
                      mobileUrl: mobileUrl,
                      rawUrl: rawUrl,
                    ),
                  ),
                );
              },
              child: Column(
                // ✅ Column — image on top, like below
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Image ──
                  Hero(
                    tag: id,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        url,
                        height: 200,
                        width: double.infinity, // ✅ full width
                        fit: BoxFit.cover,
                        cacheWidth: cacheW,
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
                ],
              ),
            ),
            // ── Like Button + Count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // ✅ right side
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${likeState.likeCount}',
                      key: ValueKey(likeState.likeCount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: likeState.isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => ref
                        .read(likeProvider(params).notifier)
                        .toggleLike(context), // ✅ only on tap
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        likeState.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        key: ValueKey(likeState.isLiked),
                        color: likeState.isLiked ? Colors.red : Colors.grey,
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
    );
  }
}
