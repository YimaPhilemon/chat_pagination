import 'package:flutter_chat_paginator/flutter_chat_paginator.dart';
import 'package:easy_bubble_container/easy_bubble_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ChatApp()));
}

class ChatApp extends ConsumerStatefulWidget {
  const ChatApp({super.key});

  @override
  ConsumerState<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends ConsumerState<ChatApp> {
  late final ChatPaginationController controller;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = ChatPaginationController(
      ref: ref,
      preloadOffset: 5,
      onPageRequestCallback: (pageIndex, pageSize) async {
        await Future.delayed(const Duration(seconds: 2));

        final newMessages = List.generate(
          pageSize,
          (i) => (
            id: 'msg-$pageIndex-$i',
            text: 'Message ${pageIndex + 1}-${pageSize - i}',
            user: i % 2 == 0,
            createdAt: DateTime.now(),
          ),
        );

        controller.addMessages(newMessages, prepend: true);
      },
    );

    controller.loadFirstPage();
  }

  void _sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final newMessage = (
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      user: true,
      createdAt: DateTime.now(),
    );

    controller.addMessage(newMessage);
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Chat Pagination')),
        body: Column(
          children: [
            Expanded(
              child: ChatPaginationView(
                showLoadingIndicator: true,
                controller: controller,
                itemBuilder: (context, index, message) {
                  final isUser = message.user == true;

                  return _BubbleItem(
                    key: ValueKey(message.id),
                    label: message.text,
                    side: isUser ? BubbleSide.right : BubbleSide.left,
                    color:
                        isUser ? Colors.green.shade50 : Colors.orange.shade50,
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                  );
                },

                onItemKey: (index) => controller.messages[index].id,
              ),
            ),

            // 👇 Input area
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

class _BubbleItem extends StatelessWidget {
  final String label;
  final BubbleSide side;
  final Color color;
  final AlignmentGeometry alignment;

  const _BubbleItem({
    super.key,
    required this.label,
    required this.side,
    required this.color,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: BubbleContainer(
          side: side,
          color: color,
          borderColor: Colors.transparent,
          arrowSize: 14,
          borderRadius: 12,
          arrowPosition: 9,
          padding: EdgeInsets.all(16),
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
