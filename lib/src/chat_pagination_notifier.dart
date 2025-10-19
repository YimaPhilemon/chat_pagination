import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the current state of the chat pagination system.
/// Holds all messages, loading state, pagination progress, etc.
class ChatPaginationState {
  /// The list of currently loaded chat messages.
  final List<dynamic> messages;

  /// Whether a page is currently being loaded.
  final bool isLoading;

  /// Whether there are more pages to load.
  /// When `false`, pagination stops automatically.
  final bool hasMore;

  /// The index of the current page (starts from 0).
  final int currentPage;

  ChatPaginationState({
    required this.messages,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
  });

  /// Creates a new state object by copying the current one
  /// and overriding specific properties.
  ChatPaginationState copyWith({
    List<dynamic>? messages,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return ChatPaginationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// A Riverpod [StateNotifier] that controls pagination behavior
/// and manages updates to the [ChatPaginationState].
///
/// It exposes helper methods to modify the message list,
/// track loading state, and manage pagination logic.
class ChatPaginationNotifier extends StateNotifier<ChatPaginationState> {
  /// Initializes the notifier with an empty message list.
  ChatPaginationNotifier() : super(ChatPaginationState(messages: []));

  /// Adds multiple messages to the current message list.
  ///
  /// If [prepend] is `true`, the new messages are added to the beginning
  /// (useful for loading older messages when scrolling up).
  /// Otherwise, messages are appended to the end (default for new messages).
  void addMessages(List<dynamic> newMessages, {bool prepend = false}) {
    final updated =
        prepend
            ? [...newMessages, ...state.messages] // prepend
            : [...state.messages, ...newMessages]; // append
    state = state.copyWith(messages: updated);
  }

  /// Adds a single new message to the list.
  ///
  /// If [prepend] is `true`, it inserts the message at the top;
  /// otherwise, it goes at the bottom.
  void addMessage(dynamic newMessage, {bool prepend = true}) {
    final updated =
        prepend
            ? [newMessage, ...state.messages]
            : [...state.messages, newMessage];
    state = state.copyWith(messages: updated);
  }

  /// Updates the loading flag in the state.
  /// Used to indicate when a page request is in progress.
  void setLoading(bool value) => state = state.copyWith(isLoading: value);

  /// Updates the `hasMore` flag to control whether further pagination is allowed.
  void setHasMore(bool value) => state = state.copyWith(hasMore: value);

  /// Moves the pagination pointer to the next page.
  void incrementPage() =>
      state = state.copyWith(currentPage: state.currentPage + 1);

  /// Clears all loaded messages and resets to an empty list.
  void resetMessages() => state = ChatPaginationState(messages: []);

  /// Resets the current page index back to 0 (first page).
  void resetCurrentPage() => state = state.copyWith(currentPage: 0);
}
