import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/github/controllers/github_auth_controller.dart';
import 'package:template/features/github/widgets/forest_loading_widget.dart';

/// GitHub 로그인 화면
class GithubLoginScreen extends ConsumerStatefulWidget {
  /// GithubLoginScreen 생성자
  const GithubLoginScreen({super.key});

  @override
  ConsumerState<GithubLoginScreen> createState() => _GithubLoginScreenState();
}

class _GithubLoginScreenState extends ConsumerState<GithubLoginScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your GitHub token')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 사용자 인증
      await ref
          .read(githubAuthProvider.notifier)
          .authenticateWithToken(token);

      if (mounted) {
        final authState = ref.read(githubAuthProvider);
        await authState.when(
          data: (user) async {
            if (user != null && mounted) {
              // 로딩 화면으로 이동 (로딩 위젯이 자동으로 stats를 로드하고 forest 화면으로 이동)
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ForestLoadingWidget(token: token),
                ),
              );
            }
          },
          loading: () async {},
          error: (error, _) async {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed: $error')),
              );
            }
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFFF8FAFC),
              Color(0xFFE0F2FE),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Text(
                      'Connect your\nGitHub',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        height: 1.25,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // Description
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 56,
                      top: 4,
                    ),
                    child: Text(
                      'We read your repositories and visualize\nthem as living trees in your personal forest.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.5,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),

                  // Input Field
                  SizedBox(
                    width: 326,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'GitHub Personal Access Token',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.5,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),

                        // Text Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x1A0F172A),
                                offset: const Offset(0, 8),
                                blurRadius: 24,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _tokenController,
                            obscureText: true,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'ghp_********************************',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: const Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 17,
                              ),
                            ),
                          ),
                        ),

                        // Info Text
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 12,
                          ),
                          child: Text(
                            'Token is only used to read your repos. This stays local\nfor this demo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 44,
                      bottom: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14B8A6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                          shadowColor: const Color(0xFF14B8A6),
                        ).copyWith(
                          shadowColor: WidgetStateProperty.all(
                            const Color(0xFF14B8A6),
                          ),
                          elevation: WidgetStateProperty.all(20),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Generate My Forest',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.5,
                                  letterSpacing: 1.5 * 0.01,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
