import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod/riverpod.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseStorage = FirebaseStorage.instance;
final _firebaseFirestore = FirebaseFirestore.instance;

class AuthNotifier extends StateNotifier<Map<String, dynamic>> {
  AuthNotifier()
      : super({
          'username': '',
          'email': '',
          'photo_url': '',
          'chat_group_list': [],
        });

  //when user log in or is already log in
  void initAuthProvider() {
    if (state['email'] == '') {
      final user = _firebaseAuth.currentUser;

      state = {
        'username': user!.displayName,
        'email': user.email,
        'photo_url': user.photoURL,
      };
    }
  }

  void signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    initAuthProvider();
  }

  void signOut() {
    state = {
      'username': '',
      'email': '',
      'photo_url': '',
    };
    _firebaseAuth.signOut();
  }

  // when user create account
  void createAccount(String username, String email, String password,
      File selectedImage) async {
    final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    userCredentials.user?.updateDisplayName(username);

    final storageRef = _firebaseStorage
        .ref()
        .child('user_images')
        .child('${userCredentials.user!.uid}.jpg');

    await storageRef.putFile(selectedImage);
    final photoURL = await storageRef.getDownloadURL();

    userCredentials.user!.updatePhotoURL(photoURL);

    await _firebaseFirestore
        .collection('users')
        .doc(userCredentials.user!.uid)
        .set({
      'username': username,
      'email': email,
      'image_url': photoURL,
      'create_date': DateTime.now(),
    });

    state = {
      'username': username,
      'email': email,
      'photo_url': photoURL,
      'chat_group_list': [],
    };
  }
}

final userAuthProvider =
    StateNotifierProvider<AuthNotifier, Map<String, dynamic>>((ref) {
  return AuthNotifier();
});
