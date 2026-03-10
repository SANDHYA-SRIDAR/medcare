import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../widgets/profile_menu_button.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.senderRole});

  final String senderRole;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.senderRole} Chat'),
        actions: [
          IconButton(
            onPressed: () async {
              await NotificationService.instance.showNow(
                id: 440,
                title: 'Voice call shortcut',
                body:
                    'Starting a ${widget.senderRole.toLowerCase()} voice call flow.',
              );
            },
            icon: const Icon(Icons.call_rounded),
          ),
          IconButton(
            onPressed: () async {
              await NotificationService.instance.showNow(
                id: 441,
                title: 'Video call shortcut',
                body:
                    'Starting a ${widget.senderRole.toLowerCase()} video call flow.',
              );
            },
            icon: const Icon(Icons.videocam_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileMenuButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                final alignment = message.fromGuardian
                    ? Alignment.centerRight
                    : Alignment.centerLeft;
                final color = message.fromGuardian
                    ? const Color(0xFFDDF7F2)
                    : const Color(0xFFF1F5F9);

                return Align(
                  alignment: alignment,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.author,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(message.message),
                        const SizedBox(height: 6),
                        Text(
                          message.timeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Send a care update...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton.small(
                    onPressed: () {
                      context.read<MedCareState>().addChatMessage(
                        author: widget.senderRole,
                        message: _messageController.text,
                        senderRole: widget.senderRole,
                      );
                      _messageController.clear();
                    },
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
