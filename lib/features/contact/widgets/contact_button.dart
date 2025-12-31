import 'package:flutter/material.dart';
import 'package:repo_arborist/features/contact/screens/contact_screen.dart';

class ContactButton extends StatelessWidget {
  const ContactButton({
    required this.patOwner, // 외부에서 받음
    required this.repositoryOwner, // 외부에서 받음
    super.key,
  });

  final String patOwner;
  final String repositoryOwner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
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
      ),
    );
  }
}
