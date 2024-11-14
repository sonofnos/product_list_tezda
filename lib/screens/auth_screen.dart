import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLoginMode) {
      ref.read(authProvider.notifier).login(email, password, context);
    } else {
      ref.read(authProvider.notifier).register(email, password, context);
    }
  }

  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          ref.read(authProvider.notifier).tryAutoLogin();
          context.go('/home');
        });
      }
    } catch (e) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLoginMode ? 'Login' : 'Register'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _switchAuthMode,
              child: Text(_isLoginMode
                  ? 'Create an account'
                  : 'I already have an account'),
            ),
            if (authState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${authState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (authState.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
