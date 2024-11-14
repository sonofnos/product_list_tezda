import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final _firebaseAuth = FirebaseAuth.instance;

  AuthNotifier() : super(const AsyncValue.data(null)) {
    tryAutoLogin();
  }

  Future<void> register(
      String email, String password, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(userCredential.user);
      context.go('/home');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(_firebaseAuth.currentUser);
      context.go('/home');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await _firebaseAuth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> tryAutoLogin() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        state = AsyncValue.data(user);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
