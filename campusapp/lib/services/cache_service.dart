import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String eventsBoxName = 'events_cache';
  static const String postsBoxName = 'posts_cache';
  static const String chatBoxName = 'chat_history';

  static Future<void> init() async {
    await Hive.openBox(eventsBoxName);
    await Hive.openBox(postsBoxName);
    await Hive.openBox(chatBoxName);
  }

  // --- Events ---
  static Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    final box = Hive.box(eventsBoxName);
    await box.put('latest_events', events);
  }

  static List<dynamic> getCachedEvents() {
    final box = Hive.box(eventsBoxName);
    return box.get('latest_events', defaultValue: []);
  }

  // --- Posts ---
  static Future<void> savePosts(List<Map<String, dynamic>> posts) async {
    final box = Hive.box(postsBoxName);
    await box.put('latest_posts', posts);
  }

  static List<dynamic> getCachedPosts() {
    final box = Hive.box(postsBoxName);
    return box.get('latest_posts', defaultValue: []);
  }

  // --- AI Chat History ---
  static Future<void> saveChatMessage(String userId, Map<String, dynamic> message) async {
    final box = Hive.box(chatBoxName);
    final history = box.get(userId, defaultValue: []) as List;
    history.add(message);
    await box.put(userId, history);
  }

  static List<dynamic> getChatHistory(String userId) {
    final box = Hive.box(chatBoxName);
    return box.get(userId, defaultValue: []);
  }

  static Future<void> clearCache() async {
    await Hive.box(eventsBoxName).clear();
    await Hive.box(postsBoxName).clear();
  }

  static Future<void> clearChatHistory(String userId) async {
    await Hive.box(chatBoxName).delete(userId);
  }
}
