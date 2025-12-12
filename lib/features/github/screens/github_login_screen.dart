import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/github/controllers/github_auth_controller.dart';
import 'package:repo_arborist/features/github/controllers/github_pat_controller.dart';
import 'package:repo_arborist/features/github/widgets/forest_loading_widget.dart';

/// GitHub login screen with 3 tabs
class GithubLoginScreen extends ConsumerStatefulWidget {
  /// Constructor
  const GithubLoginScreen({super.key});

  @override
  ConsumerState<GithubLoginScreen> createState() => _GithubLoginScreenState();
}

class _GithubLoginScreenState extends ConsumerState<GithubLoginScreen> {
  final _freeUsernameController = TextEditingController();
  final _tokenController = TextEditingController();
  final _premiumUsernameController = TextEditingController();
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _freeUsernameController.dispose();
    _tokenController.dispose();
    _premiumUsernameController.dispose();
    super.dispose();
  }

  /// Handle Free Trial login (Tab 0)
  Future<void> _handleFreeLogin() async {
    final username = _freeUsernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your GitHub username')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(githubAuthProvider.notifier)
          .authenticateWithUsername(username);

      if (mounted) {
        final authState = ref.read(githubAuthProvider);
        await authState.when(
          data: (user) async {
            if (user != null && mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      ForestLoadingWidget(username: user.login),
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

  /// Handle PAT registration (Tab 1)
  Future<void> _handleTokenRegister() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your GitHub token')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Authenticate to get username
      await ref.read(githubAuthProvider.notifier).authenticateWithToken(token);

      if (mounted) {
        final authState = ref.read(githubAuthProvider);
        await authState.when(
          data: (user) async {
            if (user != null && mounted) {
              // Save PAT to secure storage
              final success = await ref
                  .read(githubPATProvider.notifier)
                  .registerPAT(token, username: user.login);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PAT registered successfully! ✅'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
                _tokenController.clear();
                setState(() => _selectedTabIndex = 2); // Move to Premium tab
              }
            }
          },
          loading: () async {},
          error: (error, _) async {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration failed: $error')),
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

  /// Handle Premium search (Tab 2)
  Future<void> _handlePremiumSearch() async {
    final username = _premiumUsernameController.text.trim();
    final patState = ref.read(githubPATProvider);

    if (!patState.isRegistered || patState.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register PAT first')),
      );
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter GitHub username to search')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ForestLoadingWidget(
              token: patState.token,
              username: username,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle PAT deletion
  Future<void> _handleDeletePAT() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete PAT',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete your registered PAT?',
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
              'Delete',
              style: TextStyle(color: Color(0xFFF43F5E)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(githubPATProvider.notifier).deletePAT();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PAT deleted successfully'),
            backgroundColor: Color(0xFF64748B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patState = ref.watch(githubPATProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Text(
                      'Connect your\nGitHub',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        height: 1.25,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // Description
                  const Padding(
                    padding: EdgeInsets.only(
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
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),

                  // Tab Selector (3 tabs)
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
                            label: 'Guest',
                            isSelected: _selectedTabIndex == 0,
                            onTap: () => setState(() => _selectedTabIndex = 0),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            label: 'Token',
                            isSelected: _selectedTabIndex == 1,
                            onTap: () => setState(() => _selectedTabIndex = 1),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            label: 'Search',
                            isSelected: _selectedTabIndex == 2,
                            isDisabled: !patState.isRegistered,
                            onTap: patState.isRegistered
                                ? () => setState(() => _selectedTabIndex = 2)
                                : null,
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
                        ? _buildFreeInput()
                        : _selectedTabIndex == 1
                        ? _buildRegisterInput(patState)
                        : _buildPremiumInput(patState),
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
                                  ? _handleFreeLogin
                                  : _selectedTabIndex == 1
                                  ? (patState.isRegistered
                                        ? null
                                        : _handleTokenRegister)
                                  : _handlePremiumSearch),
                        style:
                            ElevatedButton.styleFrom(
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
                                _selectedTabIndex == 0
                                    ? 'Try for Free'
                                    : _selectedTabIndex == 1
                                    ? (patState.isRegistered
                                          ? 'Already Registered ✅'
                                          : 'Register PAT')
                                    : 'Search with Token',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.5,
                                  letterSpacing: 0.01,
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

  /// Build Free Trial input (Tab 0)
  Widget _buildFreeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'GitHub Username',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0F172A),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: TextField(
            controller: _freeUsernameController,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: 'octocat',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 17,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 12,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Limited to 20 repositories maximum',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Only public repositories will be visible.\nNo token required.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Register PAT input (Tab 1)
  Widget _buildRegisterInput(GitHubPATState patState) {
    if (patState.isRegistered) {
      // Already registered - show status and delete button
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981), width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Color(0xFF059669),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PAT Registered',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Username: ${patState.username ?? "Unknown"}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF047857),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleDeletePAT,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete PAT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF43F5E),
                      side: const BorderSide(
                        color: Color(0xFFF43F5E),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Not registered - show input field
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'GitHub Personal Access Token',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0F172A),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: TextField(
            controller: _tokenController,
            obscureText: true,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: 'ghp_********************************',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 17,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 12,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Color(0xFF059669)),
                    SizedBox(width: 8),
                    Text(
                      'Access 1000+ repositories',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Access private repos and more details.\nToken is securely encrypted on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Premium search input (Tab 2)
  Widget _buildPremiumInput(GitHubPATState patState) {
    if (!patState.isRegistered) {
      // PAT not registered - show disabled state
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Column(
          children: [
            Icon(Icons.lock_outline, size: 48, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Premium Search Locked',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Register your PAT first to unlock premium search',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    // PAT registered - show search input
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Search GitHub User',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0F172A),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: TextField(
            controller: _premiumUsernameController,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: 'torvalds, microsoft, google...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 17,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 12,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD6FE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF9333EA)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      size: 16,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Powered by your PAT (${patState.username})',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Search any GitHub user\'s repositories.\nUsing your PAT for unlimited access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tab button widget
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 2),
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
            color: isDisabled
                ? const Color(0xFFCBD5E1)
                : isSelected
                ? const Color(0xFF14B8A6)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
