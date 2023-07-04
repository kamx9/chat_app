import 'package:chat_app/models/chat_group.dart';
import 'package:chat_app/widgets/chat_message.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:chat_app/widgets/qr_image.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatGroup});
  final ChatGroup chatGroup;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _showQR() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => QRImage(chatGroup: widget.chatGroup),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatGroup.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showQR,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              chatGroup: widget.chatGroup,
            ),
          ),
          NewMessage(
            chatGroup: widget.chatGroup,
          ),
        ],
      ),
    );
  }
}
