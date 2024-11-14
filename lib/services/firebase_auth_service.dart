// // lib/services/firebase_auth_service.dart
// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:go_router/go_router.dart';

// enum AuthStatus {
//   initial,
//   authenticated,
//   unauthenticated,
//   error,
// }

// class AuthState {
//   final User? user;
//   final AuthStatus status;
//   final String? errorMessage;

//   AuthState({
//     this.user,
//     this.status = AuthStatus.initial,
//     this.errorMessage,
//   });

//   AuthState copyWith({
//     User? user,
//     AuthStatus? status,
//     String? errorMessage,
//   }) {
//     return AuthState(
//       user: user ?? this.user,
//       status: status ?? this.status,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }

// class AuthNotifier extends StateNotifier<AuthState> {
//   final FirebaseAuth _auth;
//   final FlutterSecureStorage _storage;
//   StreamSubscription<User?>? _authStateSubscription;
//   Timer? _sessionTimer;

//   // Session timeout duration - 1 hour
//   static const sessionTimeout = Duration(hours: 1);

//   AuthNotifier({
//     required FirebaseAuth auth,
//     required FlutterSecureStorage storage,
//   })  : _auth = auth,
//         _storage = storage,
//         super(AuthState()) {
//     _initialize();
//   }

//   void _initialize() {
//     _authStateSubscription = _auth.authStateChanges().listen((user) {
//       if (user != null) {
//         _handleSignedInUser(user);
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.unauthenticated,
//           user: null,
//         );
//       }
//     });
//   }

//   Future<void> _handleSignedInUser(User user) async {
//     final token = await user.getIdToken();
//     await _storage.write(key: 'auth_token', value: token);

//     state = state.copyWith(
//       status: AuthStatus.authenticated,
//       user: user,
//     );

//     _resetSessionTimer();
//   }

//   void _resetSessionTimer() {
//     _sessionTimer?.cancel();
//     _sessionTimer = Timer(sessionTimeout, () {
//       logout(expired: true);
//     });
//   }

//   Future<void> register({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       state = state.copyWith(status: AuthStatus.initial);

//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       await _handleSignedInUser(userCredential.user!);
//       context.go('/home');
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: _getErrorMessage(e.code),
//       );
//     }
//   }

//   Future<void> login({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       state = state.copyWith(status: AuthStatus.initial);

//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       await _handleSignedInUser(userCredential.user!);
//       context.go('/home');
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: _getErrorMessage(e.code),
//       );
//     }
//   }

//   // Sign out
//   Future<void> logout({bool expired = false}) async {
//     try {
//       await _auth.signOut();
//       await _storage.delete(key: 'auth_token');
//       _sessionTimer?.cancel();

//       state = state.copyWith(
//         status: AuthStatus.unauthenticated,
//         user: null,
//         errorMessage: expired ? 'Session expired. Please sign in again.' : null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: 'Failed to sign out',
//       );
//     }
//   }

//   // Refresh the session
//   Future<void> refreshSession() async {
//     if (state.user != null) {
//       final token = await state.user!.getIdToken(true);
//       await _storage.write(key: 'auth_token', value: token);
//       _resetSessionTimer();
//     }
//   }

//   // Get user token
//   Future<String?> getToken() async {
//     return await _storage.read(key: 'auth_token');
//   }

//   String _getErrorMessage(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'No user found with this email.';
//       case 'wrong-password':
//         return 'Wrong password provided.';
//       case 'email-already-in-use':
//         return 'Email is already in use.';
//       case 'invalid-email':
//         return 'Invalid email address.';
//       case 'weak-password':
//         return 'Password is too weak.';
//       default:
//         return 'An error occurred. Please try again.';
//     }
//   }

//   @override
//   void dispose() {
//     _authStateSubscription?.cancel();
//     _sessionTimer?.cancel();
//     super.dispose();
//   }
// }

// // Provider for auth service
// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   return AuthNotifier(
//     auth: FirebaseAuth.instance,
//     storage: const FlutterSecureStorage(),
//   );
// });
