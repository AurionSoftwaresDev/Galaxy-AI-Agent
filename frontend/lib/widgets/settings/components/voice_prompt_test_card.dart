import 'package:flutter/material.dart';

/// Card component inside SettingsDialog for dispatching direct test utterances
/// to Galaxy AI via `POST /agent/generate` or `WS /ws/assistant`.
class VoicePromptTestCard extends StatelessWidget {
    final TextEditingController voicePromptController;
    final VoidCallback onSend;

    const VoicePromptTestCard({
        super.key,
        required this.voicePromptController,
        required this.onSend,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    'Dispatch Utterance to /ws/assistant',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                    ),
                ),
                const SizedBox(height: 6),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                        Expanded(
                            child: TextField(
                                controller: voicePromptController,
                                minLines: 1,
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                onSubmitted: (_) => onSend(),
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: Color(0xFFF1F5F9),
                                ),
                                decoration: InputDecoration(
                                    isDense: true,
                                    hintText:
                                        'Speak or enter command for Galaxy AI...',
                                    hintStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF111827),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1E293B),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: onSend,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06B6D4),
                                foregroundColor: const Color(0xFF07090E),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                ),
                            ),
                            child: const Text(
                                'Send',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ),
                    ],
                ),
            ],
        );
    }
}
