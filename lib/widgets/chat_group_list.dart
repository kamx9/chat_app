import 'package:chat_app/models/chat_group.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:flutter/material.dart';

class ChatGroupList extends StatelessWidget {
  const ChatGroupList({super.key, required this.chatGroupList});
  final List<ChatGroup> chatGroupList;

  @override
  Widget build(BuildContext context) {
    if (chatGroupList.isEmpty) {
      return Center(
        child: Text(
          'No chat groups added yet',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
      );
    }
    return ListView.builder(
      itemCount: chatGroupList.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: Icon(Icons.chat_bubble),
        title: Text(
          chatGroupList[index].groupName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('jakiś tekst'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ChatScreen(
                chatGroup: chatGroupList[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
