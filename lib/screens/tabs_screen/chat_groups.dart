import 'package:chat_app/providers/user_chat_group_provider.dart';
import 'package:chat_app/widgets/chat_group_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatGroupsScreen extends ConsumerStatefulWidget {
  const ChatGroupsScreen({super.key});

  @override
  ConsumerState<ChatGroupsScreen> createState() {
    return _ChatGroupsScreenState();
  }
}

class _ChatGroupsScreenState extends ConsumerState<ChatGroupsScreen> {
  late Future<void> _chatGroupsFuture;

  @override
  void initState() {
    super.initState();
    _chatGroupsFuture =
        ref.read(userChatGroupsProvider.notifier).loadUserChatGroups();
  }

  @override
  Widget build(BuildContext context) {
    final userChatGroups = ref.watch(userChatGroupsProvider);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: FutureBuilder(
        future: _chatGroupsFuture,
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : ChatGroupList(
                    chatGroupList: userChatGroups,
                  ),
      ),
    );
  }
}
