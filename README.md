<p align="center">                    
  <a href="https://img.shields.io/badge/License-MIT-green">
    <img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">
  </a>                    
  <a href="https://github.com/YimaPhilemon/chat_pagination/stargazers">
    <img src="https://img.shields.io/github/stars/YimaPhilemon/chat_pagination?style=flat&logo=github&colorB=green&label=stars" alt="GitHub stars">
  </a>                    
  <a href="https://pub.dev/packages/chat_pagination">
    <img src="https://img.shields.io/pub/v/chat_pagination.svg?label=pub&color=orange" alt="pub version">
  </a>                    
</p>
                 

<p align="center">                  
<a href="https://www.buymeacoffee.com/yimaphilemon" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>                  
</p> 

---

# 🧩 Flutter Chat Pagination

> A lightweight and efficient **chat pagination system** for Flutter — built with **Riverpod** and **FlutterListView** for seamless infinite scrolling, smooth state handling, and full UI flexibility.

---

## 🌟 Features

- ⚡ **Infinite scrolling** — load messages in pages (up or down)
- 💬 **Customizable message builder** — you control the UI
- 🧠 **Riverpod-powered state management** — reactive and clean
- 🔄 **Smart preload thresholds** — efficient, automatic page requests
- 🎨 **Composable design** — works with any message bubble layout
- 📦 **Simple controller API** — easy to integrate and extend

---

## 🚀 Getting Started

### 1. Install the package

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_chat_pagination:
    git:
      url: https://github.com/YimaPhilemon/chat_pagination.git
```
Or 

```yaml
dependencies:
  flutter_chat_pagination: ^0.0.1
```

Then run:

```dart
flutter pub get
```
🧱 Architecture Overview
This package is built around three core layers:

Component	Type	Responsibility
ChatPaginationView	Widget	Displays the chat list and handles scroll detection
ChatPaginationController	Class	Controls pagination requests, scrolling, and triggers
ChatPaginationNotifier	StateNotifier	Manages message state, loading, and pagination flags

💡 Basic Usage
1. Import dependencies

```dart
import 'package:flutter_chat_pagination/chat_pagination_controller.dart';
import 'package:flutter_chat_pagination/chat_pagination_view.dart';
```

2. Initialize in your main app

```dart
void main() {
  runApp(const ProviderScope(child: ChatApp()));
}
```

3. Create the Chat Screen

```dart
class ChatApp extends ConsumerStatefulWidget {
  const ChatApp({super.key});

  @override
  ConsumerState<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends ConsumerState<ChatApp> {
  late final ChatPaginationController controller;

  @override
  void initState() {
    super.initState();
    controller = ChatPaginationController(
      ref: ref,
      onPageRequestCallback: (pageIndex, pageSize) async {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        final messages = List.generate(
          pageSize,
          (i) => "Message ${(pageIndex * pageSize) + i + 1}",
        );
        controller.addMessages(messages, prepend: true);
      },
    );

    controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Chat Pagination Example')),
        body: ChatPaginationView(
          controller: controller,
          itemBuilder: (context, index, message) {
            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(message),
            );
          },
        ),
      ),
    );
  }
}
```

⚙️ Configuration Options
You can tweak scrolling behavior and thresholds easily:

Parameter	Default	Description
pageMinTriggerOffset	200.0	Minimum scroll offset to trigger next page
pageMaxTriggerOffset	800.0	Maximum threshold to cap trigger distance
disableCacheItems	true	Disable item caching for dynamic lists
keepPosition	true	Maintain scroll position after updates
firstItemAlign	FirstItemAlign.start	Initial alignment of the list
padding	EdgeInsets.all(16)	List padding

🔁 Controller API Reference
Method	Description
loadFirstPage()	Loads the first page after initialization
requestNextPage()	Manually load the next page
addMessages(List messages, {bool prepend = false})	Add a list of messages
addMessage(dynamic message, {bool prepend = false})	Add a single message
reset()	Clears all messages and resets pagination
scrollToBottom({bool animated = true})	Scrolls to the newest message

🧠 State Notifier Reference
ChatPaginationNotifier extends StateNotifier<ChatPaginationState> and manages:

Property	Type	Description
messages	List<dynamic>	The current message list
isLoading	bool	Whether a page is being loaded
hasMore	bool	Indicates if more pages are available
currentPage	int	The current loaded page index

🧩 Example UI with FlutterListView
The package uses FlutterListView under the hood to handle efficient scrolling with thousands of messages. You can safely append or prepend messages without losing scroll position.

```dart
FlutterListView(
  controller: controller.listController,
  delegate: FlutterListViewDelegate(
    (context, index) {
      final message = state.messages[index];
      return ChatBubble(message: message);
    },
    childCount: state.messages.length,
  ),
);
```

🧰 Advanced Example: Preloading Logic
You can enable preload offset to stop pagination after a specific page count:

```dart
controller = ChatPaginationController(
  ref: ref,
  preloadOffset: 3, // after 3 pages, stop auto-loading
  onPageRequestCallback: (pageIndex, pageSize) async {
    ...
  },
);
```

🧼 Resetting the Chat

```dart
controller.reset(); // Clears messages and resets the current page
```

📦 Folder Structure

```vbnet
lib/
├── chat_pagination_controller.dart
├── chat_pagination_notifier.dart
└── chat_pagination_view.dart
```

💬 Future Plans
✅ Bidirectional pagination (load older & newer messages)

✅ Auto-scroll during live message streaming

🔜 Scroll anchor restoration across sessions

🔜 Integration with popular chat APIs (Firebase, Supabase, etc.)

🔜 Built-in message group headers (date separators)

🧑‍💻 Contributing
Pull requests are welcome!
If you find a bug or want to suggest an improvement, open an issue.

🪪 License
This project is licensed under the MIT License.
See the LICENSE file for details.

❤️ Credits
Developed with 💙 for the Flutter community.