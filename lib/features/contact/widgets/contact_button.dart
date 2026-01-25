import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/contact/screens/contact_screen.dart';
import 'package:repo_arborist/shared/auth/github_pat_controller.dart';

class ContactButton extends ConsumerWidget {
  const ContactButton({
    required this.repositoryOwner,
    super.key,
  });

  final String repositoryOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patState = ref.watch(githubPATProvider);
    final patOwner = patState.username ?? 'unknown';
    // Padding removed - now handled by parent widget
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactScreen(
              patOwner: patOwner,
              repositoryOwner: repositoryOwner,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0x5014B8A6),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mail_outline,
              color: Color(0xFF14B8A6),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Contact Us',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF14B8A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
