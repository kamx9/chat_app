import 'package:chat_app/models/chat_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
var _firestore = FirebaseFirestore.instance;

class UserChatGroupNotifier extends StateNotifier<List<ChatGroup>> {
  UserChatGroupNotifier() : super(const []);

  Future<void> loadUserChatGroups() async {
    List<dynamic> userChatGroupList = [];
    List<ChatGroup> finalChatGroupList = [];

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final doc = await docRef.get();

    final data = doc.data() as Map<String, dynamic>;
    userChatGroupList = data['chat_group_list'];

    final QuerySnapshot querySnapshot =
        await _firestore.collection('chat_group').get();

    if (querySnapshot.docs.isNotEmpty) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        if (userChatGroupList.contains(data['group_id'])) {
          finalChatGroupList.add(
            ChatGroup(
              groupName: data['group_name'],
              adminId: data['admin_id'],
              groupId: data['group_id'],
            ),
          );
        }
      }
    }
    state = finalChatGroupList;
  }

  void addNewGroup(String groupName) async {
    final groupNameAndId = '${groupName.replaceAll(' ', '-')}_${uuid.v4()}';

    // add group chat to list of all chats
    await _firestore.collection('chat_group').doc(groupNameAndId).set({
      'group_name': groupName,
      'group_id': groupNameAndId,
      'admin_id': FirebaseAuth.instance.currentUser!.uid,
      'create_date': DateTime.now(),
    });

    // create place for messages for this group
    await _firestore.collection(groupNameAndId).doc('init').set({});

    // add id chat to user
    final docRef = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    List<dynamic> chatGroupList = [];
    final doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    chatGroupList = data['chat_group_list'];
    chatGroupList.add(groupNameAndId);
    _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'chat_group_list': chatGroupList});

    state = [
      ...state,
      ChatGroup(
          groupName: groupName,
          adminId: FirebaseAuth.instance.currentUser!.uid,
          groupId: groupNameAndId),
    ];
  }

  void addGroup(String groupNameAndId) async {
    final docRef = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    List<dynamic> chatGroupList = [];
    final doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    chatGroupList = data['chat_group_list'];

    if (!chatGroupList.contains(groupNameAndId)) {
      chatGroupList.add(groupNameAndId);
      _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'chat_group_list': chatGroupList});

      final groupDoc =
          await _firestore.collection('chat_group').doc(groupNameAndId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      state = [
        ...state,
        ChatGroup(
            groupName: groupData['group_name'],
            adminId: FirebaseAuth.instance.currentUser!.uid,
            groupId: groupNameAndId),
      ];
    }
  }

  ChatGroup getChatGroup(String groupId) {
    return state.firstWhere((chatGroup) => chatGroup.groupId == groupId);
  }
}

final userChatGroupsProvider =
    StateNotifierProvider<UserChatGroupNotifier, List<ChatGroup>>(
        (ref) => UserChatGroupNotifier());
