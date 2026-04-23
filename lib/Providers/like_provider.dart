import 'dart:async';
import 'package:andaz/utils/check_internet.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef LikeParams = (String, String, bool, int);

final likeProvider =
    StateNotifierProvider.family<LikeNotifier, LikeState, LikeParams>(
      (ref, params) => LikeNotifier(
        postId: params.$1,
        userId: params.$2,
        initialIsLiked: params.$3,
        initialLikeCount: params.$4,
      ),
    );

class LikeNotifier extends StateNotifier<LikeState> {
  final String postId;
  final String userId;
  Timer? _debounceTimer;

  bool _serverIsLiked;
  int _serverLikeCount;

  LikeNotifier({
    required this.postId,
    required this.userId,
    required bool initialIsLiked,
    required int initialLikeCount,
  }) : _serverIsLiked = initialIsLiked,
       _serverLikeCount = initialLikeCount,
       super(LikeState(isLiked: initialIsLiked, likeCount: initialLikeCount));

  Future<void> toggleLike(BuildContext context) async {
    final newIsLiked = !state.isLiked;
    final newCount = newIsLiked ? state.likeCount + 1 : state.likeCount - 1;
    state = LikeState(isLiked: newIsLiked, likeCount: newCount);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      await _syncWithServer(context);
    });
  }

  Future<void> _syncWithServer(BuildContext context) async {
    final intendedLiked = state.isLiked;

    final hasInternet = await hasActualInternet();

    if (!hasInternet) {
      state = LikeState(isLiked: _serverIsLiked, likeCount: _serverLikeCount);
      _showSnackBar(context, '📶 No internet. Like nahi ho paya.');
      return;
    }

    try {
      await Supabase.instance.client.rpc(
        'toggle_like',
        params: {'p_post_id': postId, 'p_user_id': userId},
      );
      _serverIsLiked = intendedLiked;
      _serverLikeCount = state.likeCount;
    } catch (e) {
      state = LikeState(isLiked: _serverIsLiked, likeCount: _serverLikeCount);
      _showSnackBar(context, '❌ Like failed. Please try again.');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class LikeState {
  final bool isLiked;
  final int likeCount;

  LikeState({required this.isLiked, required this.likeCount});
}
