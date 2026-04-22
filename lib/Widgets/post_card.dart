import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatelessWidget {
  final String url;
  final String id;
  // final int? likeCount; // add karo
  // final bool? isLiked;

  const PostCard({
    required this.url,
    required this.id,
    // required this.likeCount,
    // required this.isLiked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final likeCount = 0; // Placeholder for like count
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
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Text(
                  id,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // here i am using this hero widget which makes my image to show as a zoom animation on differet screen
                // and i am using the id as the tag for hero widget which is unique for each post and it will match with the tag in the detail view to show the animation
                child: Row(
                  children: [
                    Hero(
                      // Optimized Image Loading
                      tag: id, // Ensure this matches the tag in Detail View
                      child: Image.network(
                        height: 200,
                        url,
                        // OPTIMIZATION: Decode image at smaller size to save RAM
                        cacheWidth: 600,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                    Column(
                      children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Icon(Icons.favorite),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Icon(Icons.heart_broken),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("like_count : ${likeCount ?? 0}"),
                        ),
                      ],
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
