import 'package:chat_app/models/chat_group.dart';
import 'package:chat_app/providers/user_chat_group_provider.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/tabs_screen/account.dart';
import 'package:chat_app/screens/tabs_screen/chat_groups.dart';
import 'package:chat_app/screens/tabs_screen/qr_scanner.dart';
import 'package:chat_app/screens/verify_email.dart';
import 'package:chat_app/widgets/new_chat_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  var _isVerifyEmail = FirebaseAuth.instance.currentUser!.emailVerified;

  int _selectedPageIndex = 0;

  void _openAddChatGroup() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewChatGroup(),
    );
  }

  Future<ChatGroup> _qrScanDone(String groupId) async {
    ref.read(userChatGroupsProvider.notifier).addGroup(groupId);

    setState(() {
      _selectedPageIndex = 0;
      _selectPage(_selectedPageIndex);
    });

    return await _waitAndGetChatGroup(groupId);
  }

  void _goToChatGroup(ChatGroup chatGroup) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChatScreen(
          chatGroup: chatGroup,
        ),
      ),
    );
  }

  Future<ChatGroup> _waitAndGetChatGroup(String groupId) async {
    var chatGroup;
    while (chatGroup == null) {
      chatGroup =
          ref.read(userChatGroupsProvider.notifier).getChatGroup(groupId);
      print(chatGroup);
      await Future.delayed(
          Duration(milliseconds: 100)); // Poczekaj 100 milisekund
    }
    return chatGroup;
  }

  void _showQRScanner() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => QRScannerScreen(
        done: (String groupId) async {
          _goToChatGroup(await _qrScanDone(groupId));
        },
      ),
    );
  }

  Widget activePage = ChatGroupsScreen();

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    switch (_selectedPageIndex) {
      case 0:
        activePage = ChatGroupsScreen();
        break;
      case 1:
        activePage = ChatGroupsScreen();
        _showQRScanner();
        break;
      case 2:
        activePage = AccountScreen();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerifyEmail) {
      activePage = VerifyEmailScreen(
        done: () {
          setState(() {
            activePage = ChatGroupsScreen();
            _isVerifyEmail = true;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chatini'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _openAddChatGroup,
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: activePage,
      bottomNavigationBar: !_isVerifyEmail
          ? null
          : BottomNavigationBar(
              onTap: _selectPage,
              currentIndex: _selectedPageIndex,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: 'Add',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  label: 'Account',
                ),
              ],
            ),
    );
  }
}
