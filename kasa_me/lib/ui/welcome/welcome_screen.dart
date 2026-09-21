import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainBackgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Brand badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Kasa Me · Speak for yourself',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'A voice that\nlearns how\nyou speak.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'On-device, offline-first assistive communication for people with atypical speech — in English and Ghanaian languages.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(),
                    // Avatar hero
                    Center(
                      child: Hero(
                        tag: 'voice_avatar',
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCyan.withOpacity(0.35),
                                blurRadius: 48,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/voice_avatar.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Feature pills
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _pill('🔒 Fully offline'),
                        _pill('🧠 Learns your voice'),
                        _pill('🇬🇭 Ghanaian languages'),
                        _pill('♿ Accessible design'),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Get Started CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/language_selection'),
                        child: const Text('Get Started'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Skip for returning users
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text(
                          'Already set up? Go to app →',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
