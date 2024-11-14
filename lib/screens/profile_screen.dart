import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data available.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.photoURL ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.email ?? 'No email available',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: user.email),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  onChanged: (value) {
                    // Update email functionality
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Update profile functionality
                  },
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
