import 'dart:async';
import 'package:andaz/utils/check_internet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final likeProvider =
    StateNotifierProvider.family<LikeNotifier, LikeState, Map<String, dynamic>>(
      (ref, params) => LikeNotifier(
        postId: params['postId'] as String,
        userId: params['userId'] as String,
        initialIsLiked: params['initialIsLiked'] as bool,
        initialLikeCount: params['initialLikeCount'] as int,
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
    // 1. Turant UI update
    final newIsLiked = !state.isLiked;
    final newCount = newIsLiked ? state.likeCount + 1 : state.likeCount - 1;
    state = LikeState(isLiked: newIsLiked, likeCount: newCount);

    // 2. Debounce — 800ms baad ek hi call jaayegi
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      await _syncWithServer(context);
    });
  }

  Future<void> _syncWithServer(BuildContext context) async {
    final intendedLiked = state.isLiked;

    // 3. Internet check
    final hasInternet = await hasActualInternet();

    if (!hasInternet) {
      // Revert karo
      state = LikeState(isLiked: _serverIsLiked, likeCount: _serverLikeCount);
      _showSnackBar(context, '📶 No internet. Like nahi ho paya.');
      return;
    }

    // 4. RPC call
    try {
      await Supabase.instance.client.rpc(
        'toggle_like',
        params: {'p_post_id': postId, 'p_user_id': userId},
      );

      // Server sync successful
      _serverIsLiked = intendedLiked;
      _serverLikeCount = state.likeCount;
    } catch (e) {
      // Revert karo
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
