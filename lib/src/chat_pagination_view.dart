import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_pagination_controller.dart';

/// A scrollable chat view that automatically requests new pages of messages
/// as the user scrolls near the top or bottom (depending on configuration).
///
/// Uses [flutter_list_view] for efficient large list rendering,
/// and integrates with a [ChatPaginationController] to handle pagination logic.
class ChatPaginationView extends ConsumerStatefulWidget {
  /// The controller that manages pagination state and scroll behavior.
  final ChatPaginationController controller;

  /// Builder used to render each message item.
  /// Parameters: (BuildContext context, int index, dynamic message)
  final Widget Function(BuildContext, int, dynamic) itemBuilder;

  /// Optional builder shown when messages are loading.
  final WidgetBuilder? loadingBuilder;

  /// Optional builder shown when there are no messages.
  final WidgetBuilder? emptyBuilder;

  /// Optional callback used to mark certain items as permanent (non-recycled).
  final bool Function(String)? onIsPermanent;

  /// Optional callback to provide a unique key for each list item.
  final String Function(int)? onItemKey;

  /// Determines how the first item aligns when scrolled into view.
  final FirstItemAlign firstItemAlign;

  /// The minimum distance from top (in pixels) to trigger loading the next page.
  final double pageMinTriggerOffset;

  /// The maximum distance threshold to prevent overly frequent loading.
  final double pageMaxTriggerOffset;

  /// Whether to disable caching of list items.
  final bool disableCacheItems;

  /// Whether to maintain scroll position when new messages are inserted.
  final bool keepPosition;

  /// Whether to show the default circular loading indicator when loading.
  final bool showLoadingIndicator;

  /// Outer padding for the chat content.
  final EdgeInsetsGeometry padding;

  const ChatPaginationView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.pageMinTriggerOffset = 200.0,
    this.pageMaxTriggerOffset = 800.0,
    this.onIsPermanent,
    this.onItemKey,
    this.firstItemAlign = FirstItemAlign.start,
    this.disableCacheItems = true,
    this.keepPosition = true,
    this.showLoadingIndicator = false,
    this.padding = const EdgeInsets.all(16),
    this.loadingBuilder,
    this.emptyBuilder,
  });

  @override
  ConsumerState<ChatPaginationView> createState() => _ChatPaginationViewState();
}

class _ChatPaginationViewState extends ConsumerState<ChatPaginationView> {
  /// Reference to the FlutterListView controller from the pagination controller.
  late final FlutterListViewController _listController =
      widget.controller.listController;

  @override
  void initState() {
    super.initState();
    // Add scroll listener to detect when to trigger pagination.
    _listController.addListener(_onScroll);
  }

  /// Called when the list scrolls. Checks how far the user has scrolled,
  /// and requests the next page if within the threshold.
  void _onScroll() {
    if (!_listController.hasClients ||
        !_listController.position.hasContentDimensions) {
      // Skip if the list is not yet attached or has no scrollable content.
      return;
    }

    final position = _listController.position;
    final offset = position.pixels;

    // Dynamically adjust threshold based on page count (progressively smaller).
    final clampedThreshold = (600 - widget.controller.currentPage * 50).clamp(
      widget.pageMinTriggerOffset,
      widget.pageMaxTriggerOffset,
    );

    // Trigger next page if scroll offset is near the top (within threshold).
    if (offset <= clampedThreshold && offset >= 0) {
      widget.controller.requestNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch pagination state from Riverpod provider.
    final state = ref.watch(chatPaginationProvider);

    // Show empty state if no messages and not currently loading.
    if (state.messages.isEmpty && !state.isLoading) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text("No messages yet"));
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          // Show loading indicator (either custom or default).
          if (state.isLoading)
            widget.loadingBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),

          // Expanded chat list that displays messages.
          Expanded(
            child: FlutterListView(
              controller: _listController,
              delegate: FlutterListViewDelegate(
                (context, index) {
                  final msg = state.messages[index];
                  return widget.itemBuilder(context, index, msg);
                },
                childCount: state.messages.length,
                onItemKey: widget.onItemKey,
                keepPosition: widget.keepPosition,
                onIsPermanent: widget.onIsPermanent,
                disableCacheItems: widget.disableCacheItems,
                initIndex: widget.controller.initIndex,
                firstItemAlign: widget.firstItemAlign,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up scroll listener to avoid memory leaks.
    _listController.removeListener(_onScroll);
    super.dispose();
  }
}
