import 'package:flutter/material.dart';

class LargePushToTalkButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const LargePushToTalkButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isRecording ? 'Stop recording' : 'Start recording',
      hint: 'Double tap to toggle speech recording',
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isRecording ? 180 : 160,
          height: isRecording ? 180 : 160,
          decoration: BoxDecoration(
            color: isRecording 
                ? Theme.of(context).colorScheme.error 
                : Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isRecording 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).colorScheme.primary).withOpacity(0.4),
                blurRadius: isRecording ? 24 : 12,
                spreadRadius: isRecording ? 8 : 4,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              size: 64,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
