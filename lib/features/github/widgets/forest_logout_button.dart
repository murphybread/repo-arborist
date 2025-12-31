import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:repo_arborist/features/github/controllers/github_auth_controller.dart';
import 'package:repo_arborist/features/github/screens/github_login_screen.dart';

class ForestLogoutButton extends ConsumerWidget {
  const ForestLogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFF43F5E)),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          // 로그아웃 실행
          ref.read(githubAuthProvider.notifier).signOut();
          // 로그인 화면으로 이동 (모든 스택 제거)
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const GithubLoginScreen(),
            ),
            (route) => false,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x20F43F5E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0x50F43F5E),
          ),
        ),
        child: const Icon(
          Icons.logout,
          color: Color(0xFFF43F5E),
          size: 16,
        ),
      ),
    );
  }
}
