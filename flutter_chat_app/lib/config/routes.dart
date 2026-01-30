import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/chats_screen.dart';
import '../screens/chat/chat_info_screen.dart';
import '../screens/chat/group_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/account_screen.dart';
import '../screens/settings/help_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/voice_settings_screen.dart';
import '../screens/users_screen.dart';
import '../screens/settings/privacy_demo_screen.dart';
import '../widgets/main_shell.dart';

/// Non-reactive router getter for use in main.dart
final appRouter = GoRouter(
  initialLocation: '/chats',
  debugLogDiagnostics: true,
  routes: [
    // Auth routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    // Main app with bottom navigation shell
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/chats',
          name: 'chats',
          builder: (context, state) => const ChatsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    // Chat routes
    GoRoute(
      path: '/chat/:id',
      name: 'chat',
      builder: (context, state) => ChatScreen(
        chatId: state.pathParameters['id']!,
        chatName: state.uri.queryParameters['name'] ?? 'Chat',
      ),
    ),
    GoRoute(
      path: '/chat-info/:id',
      name: 'chat-info',
      builder: (context, state) => ChatInfoScreen(
        chatId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/users',
      name: 'users',
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: '/group',
      name: 'group',
      builder: (context, state) => const GroupScreen(),
    ),

    // Settings sub-routes
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/account',
      name: 'account',
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: '/help',
      name: 'help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/voice-settings',
      name: 'voice-settings',
      builder: (context, state) => const VoiceSettingsScreen(),
    ),
    GoRoute(
      path: '/privacy-demo',
      name: 'privacy-demo',
      builder: (context, state) => const PrivacyDemoScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/chats',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // If not logged in and not on auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // If logged in and on auth route, redirect to chats
      if (isLoggedIn && isAuthRoute) {
        return '/chats';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main app with bottom navigation shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => const ChatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Chat routes
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) => ChatScreen(
          chatId: state.pathParameters['id']!,
          chatName: state.uri.queryParameters['name'] ?? 'Chat',
        ),
      ),
      GoRoute(
        path: '/chat-info/:id',
        name: 'chat-info',
        builder: (context, state) => ChatInfoScreen(
          chatId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/group',
        name: 'group',
        builder: (context, state) => const GroupScreen(),
      ),

      // Settings sub-routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/voice-settings',
        name: 'voice-settings',
        builder: (context, state) => const VoiceSettingsScreen(),
      ),
      GoRoute(
        path: '/privacy-demo',
        name: 'privacy-demo',
        builder: (context, state) => const PrivacyDemoScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
