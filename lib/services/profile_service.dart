// lib/services/profile_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data() ??
        {
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
        };
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    File? photoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    // Update photo if provided
    String? photoURL;
    if (photoFile != null) {
      final ref = _storage.ref().child('profile_photos/${user.uid}');
      await ref.putFile(photoFile);
      photoURL = await ref.getDownloadURL();
    }

    // Update auth profile
    await user.updateDisplayName(displayName);
    if (email != null && email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }

    // Update Firestore profile
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'email': user.email,
      'photoURL': photoURL ?? user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final profileServiceProvider = Provider((ref) => ProfileService());
