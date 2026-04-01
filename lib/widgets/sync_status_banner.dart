import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => _SyncCard(user: user),
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: LinearProgressIndicator(minHeight: 3),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: _StatusSurface(
          icon: Icons.cloud_off,
          title: 'Sync unavailable',
          subtitle: 'Firebase auth is not ready yet.',
          trailing: TextButton(
            onPressed: () => ref.read(authServiceProvider).signInWithGoogle(),
            child: const Text('Sign in'),
          ),
        ),
      ),
    );
  }
}

class _SyncCard extends ConsumerWidget {
  const _SyncCard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: _StatusSurface(
          icon: Icons.sync_problem,
          title: 'Sync not started',
          subtitle: 'Sign in again to connect notes and stickies.',
          trailing: TextButton(
            onPressed: () => ref.read(authServiceProvider).signInWithGoogle(),
            child: const Text('Sign in'),
          ),
        ),
      );
    }

    if (user!.isAnonymous) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: _StatusSurface(
          icon: Icons.cloud_upload_outlined,
          title: 'Local account only',
          subtitle:
              'Connect Google so the same notes appear on your phone and laptop.',
          trailing: FilledButton.tonalIcon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(authServiceProvider).signInWithGoogle();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cloud sync connected.')),
                );
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Google sign-in failed: $error',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.login),
            label: const Text('Connect'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: _StatusSurface(
        icon: Icons.cloud_done,
        title: 'Cloud sync connected',
        subtitle: user!.email ?? 'Signed in with Google',
        trailing: TextButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await ref.read(authServiceProvider).signOut();
            messenger.showSnackBar(
              const SnackBar(content: Text('Signed out.')),
            );
          },
          child: const Text('Sign out'),
        ),
      ),
    );
  }
}

class _StatusSurface extends StatelessWidget {
  const _StatusSurface({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
