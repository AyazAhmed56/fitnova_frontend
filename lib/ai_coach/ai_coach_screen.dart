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
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final AiCoachService _aiCoachService = AiCoachService();

  // ============================================================
  // STATE
  // ============================================================

  List<Map<String, dynamic>> _chats = [];

  List<Map<String, String>> _messages = [];

  String? _currentChatId;

  // Current selected chat theme color
  Color _currentChatColor = const Color(0xff7652e8);

  bool _isLoading = false;
  bool _isLoadingChats = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _initializeCoach();
  }

  // ============================================================
  // INITIALIZE AI COACH
  // ============================================================

  Future<void> _initializeCoach() async {
    await _loadChats();

    if (!mounted) return;

    // ------------------------------------------------------------
    // If previous chats exist:
    // Open the latest chat.
    // ------------------------------------------------------------

    if (_chats.isNotEmpty) {
      await _openChat(_chats.first["id"]);
      return;
    }

    // ------------------------------------------------------------
    // No chats:
    // Start an EMPTY temporary chat.
    //
    // IMPORTANT:
    // Nothing is inserted into Supabase here.
    // ------------------------------------------------------------

    setState(() {
      _currentChatId = null;
      _messages = [];
      _currentChatColor = const Color(0xff7652e8);
    });
  }

  // ============================================================
  // LOAD CHATS
  // ============================================================

  Future<void> _loadChats() async {
    try {
      final chats = await _aiCoachService.getChats();

      if (!mounted) return;

      setState(() {
        _chats = chats;
        _isLoadingChats = false;
      });
    } catch (e) {
      debugPrint("Load chats error: $e");

      if (!mounted) return;

      setState(() {
        _isLoadingChats = false;
      });
    }
  }

  // ============================================================
  // START NEW TEMPORARY CHAT
  // ============================================================
  //
  // This does NOT create a Supabase row.
  //
  // A real chat will only be created when the user sends
  // the first message.
  //
  // ============================================================

  void _startNewChat() {
    setState(() {
      _currentChatId = null;
      _messages = [];
      _currentChatColor = const Color(0xff7652e8);
    });

    _scrollToBottom();
  }

  // ============================================================
  // OPEN EXISTING CHAT
  // ============================================================

  Future<void> _openChat(String chatId) async {
    try {
      final messages = await _aiCoachService.getMessages(chatId);

      if (!mounted) return;

      final chat = _chats.firstWhere(
        (chat) => chat["id"] == chatId,
        orElse: () => {},
      );

      setState(() {
        _currentChatId = chatId;

        _messages = messages.map((message) {
          return {
            "sender": message["sender"].toString(),
            "message": message["message"].toString(),
          };
        }).toList();

        _currentChatColor = _getChatColor(chat);
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("Open chat error: $e");
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    // ------------------------------------------------------------
    // Clear input
    // ------------------------------------------------------------

    _controller.clear();

    // ------------------------------------------------------------
    // GET CURRENT CHAT
    // ------------------------------------------------------------

    String? chatId = _currentChatId;

    // ------------------------------------------------------------
    // FIRST MESSAGE OF A NEW CHAT
    //
    // Create the database chat ONLY now.
    // ------------------------------------------------------------

    if (chatId == null) {
      try {
        final title = message.length > 35
            ? "${message.substring(0, 35)}..."
            : message;

        final chat = await _aiCoachService.createChat(title: title);

        chatId = chat["id"]?.toString();

        if (chatId == null || chatId!.isEmpty) {
          throw Exception("Chat ID was not created");
        }

        if (!mounted) return;

        setState(() {
          _currentChatId = chatId;

          _currentChatColor = _getChatColor(chat);

          // Add to local history.
          _chats.insert(0, chat);
        });
      } catch (e) {
        debugPrint("Create chat error: $e");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Unable to create chat. Please try again."),
            ),
          );
        }

        return;
      }
    }

    // ------------------------------------------------------------
    // SHOW USER MESSAGE IMMEDIATELY
    // ------------------------------------------------------------

    setState(() {
      _messages.add({"sender": "user", "message": message});

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // ----------------------------------------------------------
      // SAVE USER MESSAGE
      // ----------------------------------------------------------

      await _aiCoachService.saveMessage(
        chatId: chatId!,
        sender: "user",
        message: message,
      );

      // ----------------------------------------------------------
      // SEND TO RAILWAY FASTAPI
      //
      // FastAPI
      //   ↓
      // NLP
      //   ↓
      // ML intent
      //   ↓
      // Entity extraction
      //   ↓
      // Decision engine
      //   ↓
      // Gemini
      // ----------------------------------------------------------

      final response = await _aiCoachService.sendMessage(
        userId: user.id,
        message: message,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // SHOW AI RESPONSE
      // ----------------------------------------------------------

      setState(() {
        _messages.add({"sender": "ai", "message": response});

        _isLoading = false;
      });

      _scrollToBottom();

      // ----------------------------------------------------------
      // SAVE AI RESPONSE
      // ----------------------------------------------------------

      await _aiCoachService.saveMessage(
        chatId: chatId!,
        sender: "ai",
        message: response,
      );

      // ----------------------------------------------------------
      // REFRESH HISTORY
      // ----------------------------------------------------------

      await _loadChats();

      // Make sure current chat ID remains selected.
      if (mounted) {
        setState(() {
          _currentChatId = chatId;
        });
      }

      _scrollToBottom();
    } catch (e) {
      debugPrint("Send message error: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _messages.add({
          "sender": "ai",
          "message": "Something went wrong. Please try again.",
        });
      });

      _scrollToBottom();
    }
  }

  // ============================================================
  // PIN / UNPIN
  // ============================================================

  Future<void> _togglePin(Map<String, dynamic> chat) async {
    try {
      await _aiCoachService.togglePinChat(
        chatId: chat["id"].toString(),
        isPinned: chat["is_pinned"] == true,
      );

      await _loadChats();
    } catch (e) {
      debugPrint("Pin error: $e");
    }
  }

  // ============================================================
  // DELETE CHAT
  // ============================================================

  Future<void> _deleteChat(Map<String, dynamic> chat) async {
    final chatId = chat["id"].toString();

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
        _chats.removeWhere((item) => item["id"].toString() == chatId);
      });

      // ----------------------------------------------------------
      // If current chat was deleted:
      //
      // DO NOT create a database chat.
      // Just start an empty temporary chat.
      // ----------------------------------------------------------

      if (_currentChatId == chatId) {
        _startNewChat();
      }
    } catch (e) {
      debugPrint("Delete chat error: $e");
    }
  }

  // ============================================================
  // CHANGE CHAT COLOR
  // ============================================================

  Future<void> _changeChatColor(Map<String, dynamic> chat) async {
    final colors = [
      const Color(0xff7652e8),
      const Color(0xff2563eb),
      const Color(0xff059669),
      const Color(0xffea580c),
      const Color(0xffdb2777),
      const Color(0xff0891b2),
      const Color(0xff4f46e5),
      const Color(0xff7c3aed),
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
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.90)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Chat Theme",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: colors.map((color) {
                      final isSelected = _currentChatColor.value == color.value;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, color);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black87, width: 3)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                )
                              : null,
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

    // ------------------------------------------------------------
    // Update UI immediately
    // ------------------------------------------------------------

    if (_currentChatId == chat["id"].toString()) {
      setState(() {
        _currentChatColor = selectedColor;
      });
    }

    // ------------------------------------------------------------
    // Save color to Supabase
    // ------------------------------------------------------------

    try {
      await _aiCoachService.updateChatColor(
        chatId: chat["id"].toString(),
        color: selectedColor.value,
      );

      // ----------------------------------------------------------
      // Update local chat object too.
      // This makes sidebar update immediately.
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        final index = _chats.indexWhere(
          (item) => item["id"].toString() == chat["id"].toString(),
        );

        if (index != -1) {
          _chats[index]["color"] = selectedColor.value;
        }
      });
    } catch (e) {
      debugPrint("Update chat color error: $e");
    }
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentChatColor.withOpacity(0.05),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leadingWidth: 60,

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

        title: Text(
          "FitNova AI Coach",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _currentChatColor,
          ),
        ),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.85),
                _currentChatColor.withOpacity(0.10),
              ],
            ),
          ),
        ),
      ),

      // ========================================================
      // SIDEBAR
      // ========================================================
      drawer: _buildSidebar(),

      // ========================================================
      // CHAT BODY
      // ========================================================
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

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentChatColor.withOpacity(0.16),
            Colors.white.withOpacity(0.90),
            _currentChatColor.withOpacity(0.08),
            _currentChatColor.withOpacity(0.14),
          ],
        ),
      ),

      child: Stack(
        children: [
          // ======================================================
          // DECORATIVE GLOW 1
          // ======================================================
          Positioned(
            top: -80,
            right: -50,
            child: _glowCircle(220, _currentChatColor),
          ),

          // ======================================================
          // DECORATIVE GLOW 2
          // ======================================================
          Positioned(
            top: 220,
            left: -100,
            child: _glowCircle(230, _currentChatColor),
          ),

          // ======================================================
          // DECORATIVE GLOW 3
          // ======================================================
          Positioned(
            bottom: 100,
            right: -80,
            child: _glowCircle(240, _currentChatColor),
          ),

          // ======================================================
          // BLUR LAYER
          // ======================================================
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // ======================================================
          // CHAT CONTENT
          // ======================================================
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

              // ==================================================
              // LOADING INDICATOR
              // ==================================================
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _currentChatColor,
                    ),
                  ),
                ),

              // ==================================================
              // INPUT
              // ==================================================
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
        color: color.withOpacity(0.18),
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
                // ==================================================
                // USER MESSAGE
                // ==================================================
                gradient: isUser
                    ? LinearGradient(
                        colors: [
                          _currentChatColor,
                          _currentChatColor.withOpacity(0.72),
                        ],
                      )
                    // =================================================
                    // AI MESSAGE
                    // =================================================
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ====================================================
            // AI ICON
            // ====================================================
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: LinearGradient(
                  colors: [
                    _currentChatColor,
                    _currentChatColor.withOpacity(0.65),
                    const Color(0xff5ed9d2),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color: _currentChatColor.withOpacity(0.30),
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

            // ====================================================
            // TITLE
            // ====================================================
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

            // ====================================================
            // DESCRIPTION
            // ====================================================
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
          // ======================================================
          // TEXT FIELD
          // ======================================================
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

                    // ==================================================
                    // NORMAL BORDER
                    // ==================================================
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),

                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    // ==================================================
                    // ENABLED BORDER
                    // ==================================================
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),

                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    // ==================================================
                    // FOCUSED BORDER
                    // ==================================================
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),

                      borderSide: BorderSide(
                        color: _currentChatColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          // ======================================================
          // SEND BUTTON
          // ======================================================
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: LinearGradient(
                colors: [
                  _currentChatColor,
                  _currentChatColor.withOpacity(0.72),
                ],
              ),

              boxShadow: [
                BoxShadow(
                  color: _currentChatColor.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
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
                  // =================================================
                  // SIDEBAR HEADER
                  // =================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 12, 10),

                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            gradient: LinearGradient(
                              colors: [
                                _currentChatColor,
                                _currentChatColor.withOpacity(0.70),
                                const Color(0xff54d8d0),
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

                  // =================================================
                  // NEW CHAT
                  // =================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);

                        // IMPORTANT:
                        // Does NOT create a database row.
                        _startNewChat();
                      },

                      child: Container(
                        height: 52,

                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _currentChatColor.withOpacity(0.14),
                              _currentChatColor.withOpacity(0.08),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.add_rounded, color: _currentChatColor),

                            const SizedBox(width: 8),

                            Text(
                              "New Chat",
                              style: TextStyle(
                                color: _currentChatColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =================================================
                  // LOADING
                  // =================================================
                  if (_isLoadingChats)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _currentChatColor,
                        ),
                      ),
                    )
                  else ...[
                    // ===============================================
                    // PINNED
                    // ===============================================
                    if (_chats.any((chat) => chat["is_pinned"] == true))
                      _buildChatSection("PINNED", true),

                    // ===============================================
                    // RECENT
                    // ===============================================
                    _buildChatSection("RECENT CHATS", false),
                  ],

                  // =================================================
                  // FOOTER
                  // =================================================
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

                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: _currentChatColor,
                          ),

                          const SizedBox(width: 10),

                          const Expanded(
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

    // ------------------------------------------------------------
    // No chats
    // ------------------------------------------------------------

    if (chats.isEmpty) {
      return const SizedBox();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ========================================================
          // SECTION TITLE
          // ========================================================
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

          // ========================================================
          // CHAT LIST
          // ========================================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),

              itemCount: chats.length,

              itemBuilder: (context, index) {
                final chat = chats[index];

                final isCurrent = chat["id"].toString() == _currentChatId;

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
                    // =================================================
                    // OPEN CHAT
                    // =================================================
                    onTap: () async {
                      Navigator.pop(context);

                      await _openChat(chat["id"].toString());
                    },

                    // =================================================
                    // CHAT ICON
                    // =================================================
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

                    // =================================================
                    // TITLE
                    // =================================================
                    title: Text(
                      chat["title"] ?? "New Chat",

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // =================================================
                    // DATE
                    // =================================================
                    subtitle: _buildChatDate(chat),

                    // =================================================
                    // MENU
                    // =================================================
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
                          // ==========================================
                          // PIN
                          // ==========================================
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

                          // ==========================================
                          // COLOR
                          // ==========================================
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

                          // ==========================================
                          // DELETE
                          // ==========================================
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

    // Default color
    if (value == null) {
      return const Color(0xff7652e8);
    }

    // Supabase integer
    if (value is int) {
      return Color(value);
    }

    // Supabase may return number as String
    if (value is String) {
      final parsed = int.tryParse(value);

      if (parsed != null) {
        return Color(parsed);
      }
    }

    return const Color(0xff7652e8);
  }

  // ============================================================
  // EMPTY CHATS
  // ============================================================

  // Widget _buildEmptyChats() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           Icons.chat_bubble_outline_rounded,
  //           size: 45,
  //           color: _currentChatColor,
  //         ),

  //         const SizedBox(height: 12),

  //         const Text(
  //           "No chats yet",
  //           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  //         ),

  //         const SizedBox(height: 6),

  //         const Text(
  //           "Start a new conversation.",
  //           style: TextStyle(fontSize: 12, color: Colors.black54),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
