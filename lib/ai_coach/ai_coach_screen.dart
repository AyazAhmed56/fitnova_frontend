import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ai_coach_service.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final AiCoachService _aiCoachService = AiCoachService();

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, String>> _messages = [];

  String? _currentChatId;

  bool _isLoading = false;
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _initializeCoach();
  }

  // INITIALIZE AI COACH
  Future<void> _initializeCoach() async {
    await _loadChats();

    if (!mounted) return;

    // No chats -> create new chat
    if (_chats.isEmpty) {
      await _createNewChat();
      return;
    }

    final latestChat = _chats.first;

    final updatedAt = latestChat["updated_at"];

    if (updatedAt == null) {
      await _createNewChat();
      return;
    }

    final lastActivity = DateTime.tryParse(updatedAt.toString());

    if (lastActivity == null) {
      await _createNewChat();
      return;
    }

    final now = DateTime.now();

    final difference = now.difference(lastActivity.toLocal());

    // ------------------------------------------------------------
    // Within 1 hour -> continue previous chat
    // More than 1 hour -> create new chat
    // ------------------------------------------------------------

    if (difference <= const Duration(hours: 1)) {
      await _openChat(latestChat["id"]);
    } else {
      await _createNewChat();
    }
  }

  // LOAD CHATS
  Future<void> _loadChats() async {
    try {
      final chats = await _aiCoachService.getChats();

      if (!mounted) return;

      setState(() {
        _chats = chats;
        _isLoadingChats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingChats = false;
      });
    }
  }

  // CREATE NEW CHAT
  Future<void> _createNewChat() async {
    try {
      final chat = await _aiCoachService.createChat();

      if (!mounted) return;

      setState(() {
        _chats.removeWhere((item) => item["id"] == chat["id"]);

        _chats.insert(0, chat);

        _currentChatId = chat["id"];

        _messages = [];
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("Create chat error: $e");
    }
  }

  // OPEN CHAT
  Future<void> _openChat(String chatId) async {
    try {
      final messages = await _aiCoachService.getMessages(chatId);

      if (!mounted) return;

      setState(() {
        _currentChatId = chatId;

        _messages = messages.map((message) {
          return {
            "sender": message["sender"].toString(),
            "message": message["message"].toString(),
          };
        }).toList();
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("Open chat error: $e");
    }
  }

  // SEND MESSAGE
  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    // Safety: create chat if none exists
    if (_currentChatId == null) {
      await _createNewChat();
    }

    final chatId = _currentChatId;

    if (chatId == null) {
      return;
    }

    _controller.clear();

    setState(() {
      _messages.add({"sender": "user", "message": message});

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Save user message
      await _aiCoachService.saveMessage(
        chatId: chatId,
        sender: "user",
        message: message,
      );

      // First message becomes title
      final currentChat = _chats.firstWhere(
        (chat) => chat["id"] == chatId,
        orElse: () => {},
      );

      if (currentChat["title"] == "New Chat") {
        final title = message.length > 35
            ? "${message.substring(0, 35)}..."
            : message;

        await _aiCoachService.updateChatTitle(chatId: chatId, title: title);
      }

      // Send to FastAPI -> NLP -> ML -> Gemini
      final response = await _aiCoachService.sendMessage(
        userId: user.id,
        message: message,
      );

      if (!mounted) return;

      setState(() {
        _messages.add({"sender": "ai", "message": response});

        _isLoading = false;
      });

      // Save AI response
      await _aiCoachService.saveMessage(
        chatId: chatId,
        sender: "ai",
        message: response,
      );

      // Refresh sidebar
      await _loadChats();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _messages.add({
          "sender": "ai",
          "message": "Something went wrong. Please try again.",
        });
      });
    }
  }

  // PIN CHAT
  Future<void> _togglePin(Map<String, dynamic> chat) async {
    try {
      await _aiCoachService.togglePinChat(
        chatId: chat["id"],
        isPinned: chat["is_pinned"] ?? false,
      );

      await _loadChats();
    } catch (e) {
      debugPrint("Pin error: $e");
    }
  }

  // DELETE CHAT
  Future<void> _deleteChat(Map<String, dynamic> chat) async {
    final chatId = chat["id"];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Chat?"),
          content: const Text(
            "This chat and all its messages will be deleted.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _aiCoachService.deleteChat(chatId);

      if (!mounted) return;

      setState(() {
        _chats.removeWhere((item) => item["id"] == chatId);
      });

      // If currently opened chat was deleted
      if (_currentChatId == chatId) {
        await _createNewChat();
      }
    } catch (e) {
      debugPrint("Delete chat error: $e");
    }
  }

  // CHANGE CHAT COLOR
  Future<void> _changeChatColor(Map<String, dynamic> chat) async {
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];

    final selectedColor = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Chat Color",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, color);
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedColor == null) return;

    await _aiCoachService.updateChatColor(
      chatId: chat["id"],
      color: selectedColor.value,
    );

    await _loadChats();
  }

  // SCROLL
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f0ff),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        // BACK + SIDEBAR
        leadingWidth: 100,

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: const Text(
          "FitNova AI Coach",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.80),
                const Color(0xffeee7ff).withOpacity(0.70),
              ],
            ),
          ),
        ),
      ),

      drawer: _buildSidebar(),

      body: _buildChatBody(),
    );
  }

  // ============================================================
  // CHAT BODY
  // ============================================================

  Widget _buildChatBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffeee9ff),
            Color(0xffe9f7ff),
            Color(0xfff7eaff),
            Color(0xffe5fff7),
          ],
        ),
      ),

      child: Stack(
        children: [
          // Decorative glowing circles
          Positioned(
            top: -80,
            right: -50,
            child: _glowCircle(220, const Color(0xff9c6cff)),
          ),

          Positioned(
            top: 220,
            left: -100,
            child: _glowCircle(230, const Color(0xff6dd5ed)),
          ),

          Positioned(
            bottom: 100,
            right: -80,
            child: _glowCircle(240, const Color(0xffff9de2)),
          ),

          // Blur decorative layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _buildNewChatPlaceholder()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];

                          final isUser = message["sender"] == "user";

                          return _buildMessageBubble(
                            message["message"] ?? "",
                            isUser,
                          );
                        },
                      ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              _buildInput(),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GLOW CIRCLE
  // ============================================================

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 80,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),

              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xff7652e8), Color(0xff9c55e8)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.88),
                          Colors.white.withOpacity(0.62),
                        ],
                      ),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(color: Colors.white.withOpacity(0.75)),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xff202033),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NEW CHAT PLACEHOLDER
  // ============================================================

  Widget _buildNewChatPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xff7652e8),
                  Color(0xffb65cff),
                  Color(0xff5ed9d2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff8b5cf6).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            "Hi, I'm FitNova AI",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Your personal fitness & wellness coach",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: const Text(
              "Ask me anything about your health, diet or workout.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                child: TextField(
                  controller: _controller,

                  textInputAction: TextInputAction.send,

                  onSubmitted: (_) {
                    _sendMessage();
                  },

                  decoration: InputDecoration(
                    hintText: "Ask FitNova AI...",

                    hintStyle: TextStyle(color: Colors.grey.shade600),

                    filled: true,
                    fillColor: Colors.white.withOpacity(0.72),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xff7652e8),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xff7652e8), Color(0xffa855f7)],
              ),
            ),

            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,

              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Drawer(
      width: 315,
      backgroundColor: Colors.transparent,
      elevation: 0,

      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),

          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.78),
                  const Color(0xffe9ddff).withOpacity(0.70),
                  const Color(0xffdff7ff).withOpacity(0.65),
                ],
              ),

              border: Border.all(color: Colors.white.withOpacity(0.8)),
            ),

            child: SafeArea(
              child: Column(
                children: [
                  // SIDEBAR HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 12, 10),

                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff7652e8),
                                Color(0xffa855f7),
                                Color(0xff54d8d0),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FitNova AI Coach",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Your personal health coach",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  // NEW CHAT
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);

                        await _createNewChat();
                      },

                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff7652e8).withOpacity(0.14),
                              const Color(0xffa855f7).withOpacity(0.10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),

                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, color: Color(0xff7652e8)),
                            SizedBox(width: 8),
                            Text(
                              "New Chat",
                              style: TextStyle(
                                color: Color(0xff7652e8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PINNED
                  if (_chats.any((chat) => chat["is_pinned"] == true))
                    _buildChatSection("PINNED", true),

                  // RECENT
                  _buildChatSection("RECENT CHATS", false),

                  // FOOTER
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: Color(0xff7652e8),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Chats older than 30 days are automatically removed.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHAT SECTION
  // ============================================================

  Widget _buildChatSection(String title, bool pinned) {
    final chats = _chats.where((chat) {
      final isPinned = chat["is_pinned"] == true;

      return pinned ? isPinned : !isPinned;
    }).toList();

    if (chats.isEmpty) {
      return const SizedBox();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),

            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black54,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),

              itemCount: chats.length,

              itemBuilder: (context, index) {
                final chat = chats[index];

                final isCurrent = chat["id"] == _currentChatId;

                final color = _getChatColor(chat);

                return Container(
                  margin: const EdgeInsets.only(bottom: 7),

                  decoration: BoxDecoration(
                    color: isCurrent
                        ? color.withOpacity(0.13)
                        : Colors.white.withOpacity(0.35),

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(color: Colors.white.withOpacity(0.75)),
                  ),

                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(context);

                      await _openChat(chat["id"]);
                    },

                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        chat["is_pinned"] == true
                            ? Icons.push_pin_rounded
                            : Icons.chat_bubble_outline_rounded,
                        color: color,
                        size: 19,
                      ),
                    ),

                    title: Text(
                      chat["title"] ?? "New Chat",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: _buildChatDate(chat),

                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),

                      onSelected: (value) {
                        if (value == "pin") {
                          _togglePin(chat);
                        }

                        if (value == "color") {
                          _changeChatColor(chat);
                        }

                        if (value == "delete") {
                          _deleteChat(chat);
                        }
                      },

                      itemBuilder: (context) {
                        final pinned = chat["is_pinned"] == true;

                        return [
                          PopupMenuItem(
                            value: "pin",
                            child: Row(
                              children: [
                                Icon(
                                  pinned
                                      ? Icons.push_pin_rounded
                                      : Icons.push_pin_outlined,
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Text(pinned ? "Unpin" : "Pin"),
                              ],
                            ),
                          ),

                          const PopupMenuItem(
                            value: "color",
                            child: Row(
                              children: [
                                Icon(Icons.palette_outlined, size: 19),
                                SizedBox(width: 10),
                                Text("Change color"),
                              ],
                            ),
                          ),

                          const PopupMenuItem(
                            value: "delete",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 19,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHAT DATE
  // ============================================================

  Widget? _buildChatDate(Map<String, dynamic> chat) {
    final updatedAt = chat["updated_at"];

    if (updatedAt == null) {
      return null;
    }

    final date = DateTime.tryParse(updatedAt.toString());

    if (date == null) {
      return null;
    }

    final local = date.toLocal();

    return Text(
      "${local.day}/${local.month}/${local.year}",
      style: const TextStyle(fontSize: 10, color: Colors.black45),
    );
  }

  // ============================================================
  // CHAT COLOR
  // ============================================================

  Color _getChatColor(Map<String, dynamic> chat) {
    final value = chat["color"];

    if (value == null) {
      return const Color(0xff7652e8);
    }

    if (value is int) {
      return Color(value);
    }

    if (value is String) {
      final parsed = int.tryParse(value);

      if (parsed != null) {
        return Color(parsed);
      }
    }

    return const Color(0xff7652e8);
  }

  // EMPTY CHATS
  Widget _buildEmptyChats() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 45,
            color: const Color(0xff7652e8),
          ),

          const SizedBox(height: 12),

          const Text(
            "No chats yet",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          const Text(
            "Start a new conversation.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
