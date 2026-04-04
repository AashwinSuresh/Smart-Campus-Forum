import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/models/event_model.dart';
import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/pages/event_details_page.dart';
import 'package:campusapp/pages/post_details.dart';
import 'package:campusapp/services/ai_api_service.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final userId = ApiService.supabase.auth.currentUser?.id ?? 'guest';
    final history = CacheService.getChatHistory(userId);
    if (history.isNotEmpty && mounted) {
      setState(() {
        _messages.addAll(history.map((e) => Map<String, dynamic>.from(e)));
      });
      _scrollToBottom();
    }
  }

  void _saveMessage(Map<String, dynamic> msg) {
    final userId = ApiService.supabase.auth.currentUser?.id ?? 'guest';
    CacheService.saveChatMessage(userId, msg);
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMsg = {'isUser': true, 'text': text};
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _messageController.clear();
    });
    _saveMessage(userMsg);

    _scrollToBottom();

    try {
      final response = await AiApiService.sendChatQuery(text);
      
      if (mounted) {
        final aiMsg = {
          'isUser': false,
          'text': response['answer'],
          'links': response['links'],
        };
        setState(() {
          _messages.add(aiMsg);
          _isLoading = false;
        });
        _saveMessage(aiMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': "Sorry, I'm having trouble connecting right now. Please try again later.",
          });
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Campus AI',
          style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildTypingIndicator(),
            ),
          const SizedBox(height: 4),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return _AnimatedDot(index: index);
          }),
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message) {
    final bool isUser = message['isUser'] ?? false;
    final List<dynamic>? links = message['links'];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.orange.withOpacity(0.9) : AppColors.cardGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isUser ? Colors.orangeAccent : AppColors.accentBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message['text'] ?? '',
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isUser ? Colors.black : Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (links != null && links.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: links.map((link) {
                  return ActionChip(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                    label: Text(
                      link['title'] ?? 'View Details',
                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      final type = link['type'];
                      final id = link['id'].toString();

                      if (type == 'event') {
                        final event = await ApiService.fetchEventById(id);
                        if (event != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsPage(event: event)),
                          );
                        }
                      } else if (type == 'post') {
                        final post = await ApiService.fetchPostById(id);
                        if (post != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailPage(post: post)),
                          );
                        }
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        border: Border(top: BorderSide(color: AppColors.accentBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ask about events, posts...",
                hintStyle:  TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int index;
  const _AnimatedDot({required this.index});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          transform: Matrix4.translationValues(0, _animation.value, 0),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
