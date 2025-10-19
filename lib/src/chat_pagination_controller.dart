import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'chat_pagination_notifier.dart';

/// Controller for managing paginated chat messages and scroll behavior.
/// Works with [ChatPaginationNotifier] to load messages page-by-page,
/// handle infinite scrolling, and scroll to the newest message.
class ChatPaginationController {
  /// Riverpod reference for accessing state and notifier.
  final WidgetRef ref;

  /// Callback triggered whenever a new page is requested.
  /// Accepts [pageIndex] and [pageSize].
  late final Future<void> Function(int pageIndex, int pageSize)? onPageRequest;

  /// Number of messages to fetch per page.
  final int pageSize;

  /// Optional limit for how many pages can be preloaded.
  /// Once reached, pagination stops automatically.
  final int? preloadOffset;

  /// Controller for the `FlutterListView`, used to manage scroll position.
  final FlutterListViewController listController = FlutterListViewController();

  /// Creates the pagination controller.
  /// Wraps [onPageRequestCallback] with built-in loading and limit logic.
  ChatPaginationController({
    required this.ref,
    Future<void> Function(int pageIndex, int pageSize)? onPageRequestCallback,
    this.preloadOffset,
    this.pageSize = 50,
  }) {
    // Wraps callback with safety checks for loading and pagination state
    onPageRequest =
        (onPageRequestCallback == null)
            ? null
            : (int pageIndex, int pageSize) async {
              // Prevent loading if already loading, no more pages, or preload disabled
              if (state.isLoading || !state.hasMore || _canNotLoad) return;

              _markLoading(true); // mark as loading
              _checkPreloadAndMarkHasMore(
                pageIndex: pageIndex,
              ); // check preload limit
              await onPageRequestCallback(
                pageIndex,
                pageSize,
              ); // run user callback
              _markLoading(false); // mark as done loading
            };
  }

  /// Accessor for the underlying notifier.
  ChatPaginationNotifier get _notifier =>
      ref.read(chatPaginationProvider.notifier);

  /// Accessor for the current pagination state.
  ChatPaginationState get state => ref.read(chatPaginationProvider);

  /// Current page index.
  int get currentPage => state.currentPage;

  /// Index of the last message in the list.
  int get lastIndex => state.messages.length - 1;

  /// Index for initial scroll position — bottom if few messages, else top.
  int get initIndex => lastIndex <= (pageSize - 1) ? lastIndex : 0;

  /// List of all currently loaded messages.
  List<dynamic> get messages => state.messages;

  /// Loads the first page automatically once the first frame is ready.
  void loadFirstPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.resetCurrentPage();
      requestPage(pageIndex: state.currentPage);
    });
  }

  /// Requests a specific page.
  Future<void> requestPage({required int pageIndex}) async =>
      await onPageRequest?.call(pageIndex, pageSize);

  /// Adds multiple messages at once (prepend or append).
  void addMessages(List<dynamic> messages, {bool prepend = false}) =>
      _notifier.addMessages(messages, prepend: prepend);

  /// Adds a single message and scrolls to bottom.
  void addMessage(dynamic message, {bool prepend = false}) {
    _notifier.addMessage(message, prepend: prepend);
    scrollToBottom();
  }

  /// Updates loading state.
  void _markLoading(bool value) => _notifier.setLoading(value);

  /// Checks if preload limit is reached and updates `hasMore` flag.
  void _checkPreloadAndMarkHasMore({required int pageIndex}) {
    if (preloadOffset != null && (pageIndex + 1) >= preloadOffset!) {
      markHasMore(false);
    }
  }

  /// Returns true if loading is disabled by a preload limit.
  bool get _canNotLoad => preloadOffset != null && preloadOffset! <= 0;

  /// Manually updates the `hasMore` flag in state.
  void markHasMore(bool value) => _notifier.setHasMore(value);

  /// Resets both the current page index and message list.
  void reset() {
    _notifier.resetCurrentPage();
    _notifier.resetMessages();
  }

  /// Smoothly (or instantly) scrolls the list to the latest message.
  void scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = listController;

      // Guard: make sure controller is attached to a scrollable view
      if (!controller.hasClients) return;

      final position = controller.position;
      if (!position.hasContentDimensions) return;

      // Measure how far we are from the bottom
      final double distanceToBottom =
          (position.maxScrollExtent - position.pixels).abs();

      // Animation behavior constants
      const double pixelThreshold = 500.0;
      const double maxDistance = 2000.0;
      const int minDuration = 200;
      const int maxDuration = 1200;

      // Calculate dynamic scroll duration based on distance
      final int dynamicDurationMs =
          ((distanceToBottom / maxDistance) * maxDuration)
              .clamp(minDuration, maxDuration)
              .round();

      final duration = Duration(milliseconds: dynamicDurationMs);

      if (animated) {
        // Smooth scroll if far from bottom, else jump immediately
        if (distanceToBottom > pixelThreshold) {
          controller.sliverController.animateToIndex(
            lastIndex,
            duration: duration,
            curve: Curves.easeInOut,
            offsetBasedOnBottom: true,
          );
        } else {
          controller.sliverController.jumpToIndex(
            lastIndex,
            offsetBasedOnBottom: true,
          );
        }
      } else {
        // Jump instantly without animation
        controller.sliverController.jumpToIndex(
          lastIndex,
          offsetBasedOnBottom: true,
        );
      }
    });
  }

  /// Requests the next page of messages and increments the page counter.
  /// Useful for manual "Load More" actions.
  void requestNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    await requestPage(pageIndex: state.currentPage + 1);
    _notifier.incrementPage();
  }
}

/// Riverpod provider for [ChatPaginationNotifier].
/// Exposes both state and actions for pagination.
final chatPaginationProvider =
    StateNotifierProvider<ChatPaginationNotifier, ChatPaginationState>(
      (ref) => ChatPaginationNotifier(),
    );
