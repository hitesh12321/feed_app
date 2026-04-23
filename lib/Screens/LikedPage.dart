import 'package:andaz/Providers/liked_posts_provider.dart';
import 'package:andaz/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Likedpage extends ConsumerStatefulWidget {
  const Likedpage({super.key});

  @override
  ConsumerState<Likedpage> createState() => _LikedpageState();
}

class _LikedpageState extends ConsumerState<Likedpage> {
  final String kUserId = dotenv.env['USER_ID']!;
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLikedPosts = ref.watch(userLikedProvider(kUserId));

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Liked Posts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: userLikedPosts.when(
        data: (postids) {
          if (postids.isEmpty) {
            return _emptyState();
          }

          final likeimageurls = ref.watch(LikedPostsurlProvider(postids));

          return likeimageurls.when(
            loading: () => _loadingGrid(),

            error: (error, stack) => Center(child: Text('Error: $error')),

            data: (urls) {
              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),

                itemCount: urls.length,

                itemBuilder: (context, index) {
                  final postUrl = urls[index];

                  return _likedPostCard(postUrl);
                },
              );
            },
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // 🖼️ Liked Post Card UI
  Widget _likedPostCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return Container(color: Colors.grey[300]);
                },

                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),

            // ❤️ Like icon overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.red, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟡 Loading Skeleton Grid
  Widget _loadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),

      itemCount: 6,

      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // 📭 Empty State UI
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: const [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),

          SizedBox(height: 16),

          Text(
            "No liked posts yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
