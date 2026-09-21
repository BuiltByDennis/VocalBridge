import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'home_stats_notifier.dart';
import 'voice_agent_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainBackgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Hi User, Kasa Me\nHears You',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VoiceAgentScreen()),
                      ),
                      child: Hero(
                        tag: 'voice_avatar',
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCyan.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
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
                  ),
                  const Spacer(flex: 2),
                  _buildOverviewCard(context, stats),
                  const SizedBox(height: 100),
                ],
              ),
              // Floating Bottom Nav
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                  child: _buildBottomNav(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.menu, color: AppTheme.textPrimary),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 12),
              // Local user icon instead of network URL
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppTheme.primaryPurple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, HomeStatsState stats) {
    final accuracy = stats.accuracyScore.clamp(0.0, 100.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Speech Overview',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: AppTheme.darkAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 100),
                    painter: ArcPainter(fillFraction: accuracy / 100),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),
                      Text('Accuracy Score',
                          style: Theme.of(context).textTheme.bodyMedium),
                      if (stats.isLoading)
                        const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: accuracy.toStringAsFixed(0),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(fontSize: 36),
                              ),
                              TextSpan(
                                text: ' /100',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                  '${stats.wordCount} learned',
                  'Words',
                  Icons.record_voice_over,
                  const Color(0xFFFFE4E6)),
              _buildStat(
                  '${stats.phraseCount} saved',
                  'Phrases',
                  Icons.chat_bubble_outline,
                  const Color(0xFFE0E7FF)),
              _buildStat(
                  '${stats.sessionCount} total',
                  'Sessions',
                  Icons.timer,
                  const Color(0xFFDCFCE7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      String value, String title, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home (active)
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppTheme.darkAccent, shape: BoxShape.circle),
            child: const Icon(Icons.home_filled, color: Colors.white),
          ),
          // Phrasebook
          GestureDetector(
            onTap: () => context.push('/phrasebook'),
            child: const Icon(Icons.favorite_border, color: AppTheme.textSecondary),
          ),
          // Voice Agent
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoiceAgentScreen()),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: AppTheme.primaryPurple, shape: BoxShape.circle),
              child: const Icon(Icons.graphic_eq, color: Colors.white),
            ),
          ),
          // History
          GestureDetector(
            onTap: () => context.push('/history'),
            child: const Icon(Icons.history, color: AppTheme.textSecondary),
          ),
          // Settings
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double fillFraction;
  const ArcPainter({this.fillFraction = 0.82});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = const Color(0xFFD4E8A5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 3.14, 3.14, false, bgPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14,
        3.14 * fillFraction.clamp(0.0, 1.0), false, fgPaint);
  }

  @override
  bool shouldRepaint(ArcPainter oldDelegate) =>
      oldDelegate.fillFraction != fillFraction;
}
