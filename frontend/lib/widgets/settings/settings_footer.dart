import 'package:flutter/material.dart';

/// Bottom action bar of the Settings window with Cancel and Apply Changes buttons.
class SettingsFooter extends StatelessWidget {
    final VoidCallback onCancel;
    final VoidCallback onApply;

    const SettingsFooter({
        super.key,
        required this.onCancel,
        required this.onApply,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13),
                ),
                border: Border(
                    top: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                        ),
                        child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                        onPressed: onApply,
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Apply Changes'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                        ),
                    ),
                ],
            ),
        );
    }
}
