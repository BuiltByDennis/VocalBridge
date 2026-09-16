import 'package:flutter/material.dart';

class KasaMeAssistantOrb extends StatefulWidget {
  final bool isListening;
  final bool isProcessing;
  final double size;

  const KasaMeAssistantOrb({
    super.key,
    this.isListening = false,
    this.isProcessing = false,
    this.size = 120.0,
  });

  @override
  State<KasaMeAssistantOrb> createState() => _KasaMeAssistantOrbState();
}

class _KasaMeAssistantOrbState extends State<KasaMeAssistantOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.isListening ? 1.0 + (_controller.value * 0.15) : 1.0;
        final pulseAlpha = widget.isListening ? 0.4 - (_controller.value * 0.2) : 0.1;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glowing Ring
            Container(
              width: widget.size * scale * 1.3,
              height: widget.size * scale * 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (widget.isListening
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary)
                    .withValues(alpha: pulseAlpha),
              ),
            ),
            // Inner Orb Surface
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isListening
                      ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                      : [const Color(0xFF00B4D8), const Color(0xFF007A78)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isListening ? Colors.red : theme.colorScheme.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.isListening
                      ? Icons.mic
                      : widget.isProcessing
                          ? Icons.sync
                          : Icons.graphic_eq,
                  color: Colors.white,
                  size: widget.size * 0.45,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
