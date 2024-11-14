// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:product_list_tezda/providers/auth_provider.dart';

// class LoginScreen extends ConsumerWidget {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);

//     return Scaffold(
//       body: Column(
//         children: [
//           TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email')),
//           TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true),
//           ElevatedButton(
//             onPressed: () {
//               ref.read(authProvider.notifier).login(
//                   emailController.text, passwordController.text, context);
//             },
//             child: const Text("Log In"),
//           ),
//           // if (authState is AuthStateLoading) CircularProgressIndicator(),
//           // if (authState is AuthStateError) Text("Error: ${authState.error}"),
//         ],
//       ),
//     );
//   }
// }
