import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/user_repository/user_repository.dart';
import '../../router/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthStateNotifier(context.read<UserRepository>()),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'RSS Feed Reader',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightGreenAccent,
              ),
              useMaterial3: true,
            ),
            routerConfig: createRouter(
              context.read<UserRepository>(),
              context.read<AuthStateNotifier>(),
            ),
          );
        },
      ),
    );
  }
}

/// A ChangeNotifier that listens to auth state changes and notifies GoRouter
/// This should be provided at the app level to ensure proper disposal
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(this._userRepository) {
    _subscription = _userRepository.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  final UserRepository _userRepository;
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
