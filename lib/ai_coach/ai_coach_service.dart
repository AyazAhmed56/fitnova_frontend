import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AiCoachService {
  static const String baseUrl =
      "https://fitnovabackend-production.up.railway.app";

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // CREATE NEW CHAT
  // ============================================================

  Future<Map<String, dynamic>> createChat({String title = "New Chat"}) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final result = await _supabase
        .from("ai_chats")
        .insert({"user_id": user.id, "title": title})
        .select()
        .single();

    return result;
  }

  // ============================================================
  // GET USER CHATS
  // ONLY RETURN CHATS THAT CONTAIN MESSAGES
  // ============================================================

  Future<List<Map<String, dynamic>>> getChats() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final result = await _supabase
        .from("ai_chats")
        .select("*, ai_chat_messages(count)")
        .eq("user_id", user.id)
        .order("is_pinned", ascending: false)
        .order("updated_at", ascending: false);

    final chats = <Map<String, dynamic>>[];

    for (final chat in result) {
      final messageCount =
          (chat["ai_chat_messages"] as List?)?.isNotEmpty == true
          ? ((chat["ai_chat_messages"] as List).first["count"] ?? 0)
          : 0;

      // Don't show empty chats in history
      if (messageCount > 0) {
        final cleanChat = Map<String, dynamic>.from(chat);
        cleanChat.remove("ai_chat_messages");
        chats.add(cleanChat);
      }
    }

    return chats;
  }

  // ============================================================
  // GET CHAT MESSAGES
  // ============================================================

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final result = await _supabase
        .from("ai_chat_messages")
        .select()
        .eq("chat_id", chatId)
        .eq("user_id", user.id)
        .order("created_at", ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  // ============================================================
  // SAVE MESSAGE
  // ============================================================

  Future<void> saveMessage({
    required String chatId,
    required String sender,
    required String message,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase.from("ai_chat_messages").insert({
      "chat_id": chatId,
      "user_id": user.id,
      "sender": sender,
      "message": message,
    });

    await _supabase
        .from("ai_chats")
        .update({"updated_at": DateTime.now().toIso8601String()})
        .eq("id", chatId)
        .eq("user_id", user.id);
  }

  // ============================================================
  // PIN / UNPIN CHAT
  // ============================================================

  Future<void> togglePinChat({
    required String chatId,
    required bool isPinned,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase
        .from("ai_chats")
        .update({"is_pinned": !isPinned})
        .eq("id", chatId)
        .eq("user_id", user.id);
  }

  // ============================================================
  // UPDATE CHAT TITLE
  // ============================================================

  Future<void> updateChatTitle({
    required String chatId,
    required String title,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase
        .from("ai_chats")
        .update({
          "title": title,
          "updated_at": DateTime.now().toIso8601String(),
        })
        .eq("id", chatId)
        .eq("user_id", user.id);
  }

  // ============================================================
  // SEND TO AI
  // ============================================================

  Future<String> sendMessage({
    required String userId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/ai-coach/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["response"] ?? "No response received.";
      }

      print("AI Coach Error: ${response.statusCode}");
      print("AI Coach Body: ${response.body}");

      return "Something went wrong. Please try again.";
    } catch (e) {
      print("AI Coach Connection Error: $e");
      return "Unable to connect to FitNova AI Coach.";
    }
  }

  // ============================================================
  // DELETE CHAT
  // ============================================================

  Future<void> deleteChat(String chatId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase
        .from("ai_chats")
        .delete()
        .eq("id", chatId)
        .eq("user_id", user.id);
  }

  // ============================================================
  // UPDATE CHAT COLOR
  // ============================================================

  Future<void> updateChatColor({
    required String chatId,
    required int color,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase
        .from("ai_chats")
        .update({"color": color})
        .eq("id", chatId)
        .eq("user_id", user.id);
  }
}
