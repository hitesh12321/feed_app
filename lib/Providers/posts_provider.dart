import 'package:andaz/Models/post.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(FeedState()) {
    fetchInitial();
  }

  static const int _pageSize = 10;

  // Pull-to-Refresh pe call hoga
  Future<void> fetchInitial() async {
    state = FeedState(); // reset
    await _fetchPage(0);
  }

  // Scroll end pe call hoga
  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchPage(state.currentPage + 1);
  }

  Future<void> _fetchPage(int page) async {
    try {
      final offset = page * _pageSize;

      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      final newPosts = response.map((p) => Post.fromJson(p)).toList();

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        currentPage: page,
        hasMore: newPosts.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}


class FeedState {
  final List<Post> posts;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;

  FeedState({
    this.posts = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}