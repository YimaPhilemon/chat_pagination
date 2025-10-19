## 0.0.1

### 🎉 Initial Release

The first release of **flutter_chat_pagination** — a lightweight, Riverpod-powered chat pagination system for Flutter.

### ✨ Features
- Infinite scroll pagination with `FlutterListView`
- Simple `ChatPaginationController` API for handling page requests
- Reactive state management using `ChatPaginationNotifier`
- Scroll-based automatic page loading
- Configurable preload offsets and scroll thresholds
- Customizable loading and empty states
- Easy integration with any chat bubble or list item UI

### 🧱 Core Components
- **ChatPaginationController** – controls pagination logic and triggers
- **ChatPaginationView** – displays the list with scroll detection
- **ChatPaginationNotifier / State** – manages messages and load state

### 🚀 Example
A minimal working example is included in the README:
```dart
ChatPaginationView(
  controller: controller,
  itemBuilder: (context, index, message) {
    return ChatBubble(message: message);
  },
);

