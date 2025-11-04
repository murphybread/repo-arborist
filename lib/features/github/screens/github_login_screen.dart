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
  final _usernameController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  int _selectedTabIndex = 0; // 0: Public Username, 1: GitHub Token

  @override
  void dispose() {
    _usernameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleUsernameLogin() async {
    final username = _usernameController.text.trim();
    print('🔵 [Login] Username 입력됨: $username');

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your GitHub username')),
      );
      return;
    }

    setState(() => _isLoading = true);
    print('🔵 [Login] 로딩 시작...');

    try {
      // Username으로 사용자 인증
      print('🔵 [Login] authenticateWithUsername 호출 중...');
      await ref
          .read(githubAuthProvider.notifier)
          .authenticateWithUsername(username);
      print('🔵 [Login] authenticateWithUsername 완료');

      if (mounted) {
        final authState = ref.read(githubAuthProvider);
        await authState.when(
          data: (user) async {
            if (user != null && mounted) {
              // 로딩 화면으로 이동 (username 사용)
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ForestLoadingWidget(
                    username: user.login,
                  ),
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

  Future<void> _handleTokenLogin() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your GitHub token')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 토큰으로 사용자 인증
      await ref
          .read(githubAuthProvider.notifier)
          .authenticateWithToken(token);

      if (mounted) {
        final authState = ref.read(githubAuthProvider);
        await authState.when(
          data: (user) async {
            if (user != null && mounted) {
              // 로딩 화면으로 이동
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
                      bottom: 40,
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

                  // Tab Selector
                  Container(
                    width: 326,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Public Username',
                            isSelected: _selectedTabIndex == 0,
                            onTap: () => setState(() => _selectedTabIndex = 0),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            label: 'GitHub Token',
                            isSelected: _selectedTabIndex == 1,
                            onTap: () => setState(() => _selectedTabIndex = 1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Input Fields
                  SizedBox(
                    width: 326,
                    child: _selectedTabIndex == 0
                        ? _buildUsernameInput()
                        : _buildTokenInput(),
                  ),

                  // Button
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 32,
                      bottom: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_selectedTabIndex == 0
                                ? _handleUsernameLogin
                                : _handleTokenLogin),
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

  /// Public Username 입력 필드
  Widget _buildUsernameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'GitHub Username',
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
            controller: _usernameController,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'octocat',
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
            'Only public repositories will be visible.\nNo token required.',
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
    );
  }

  /// GitHub Token 입력 필드
  Widget _buildTokenInput() {
    return Column(
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
            'Access private repos and more details.\nToken is only used to read your repos.',
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
    );
  }
}

/// 탭 버튼 위젯
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
