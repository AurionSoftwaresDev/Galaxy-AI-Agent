import 'package:flutter/material.dart';

/// Top header for the automation sidebar with collapse/expand toggle button.
class SidebarHeader extends StatelessWidget {
    final bool isExpanded;
    final VoidCallback onToggleExpand;

    const SidebarHeader({
        super.key,
        required this.isExpanded,
        required this.onToggleExpand,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                    if (isExpanded) ...[
                        const Row(
                            children: [
                                Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF38BDF8)),
                                SizedBox(width: 8),
                                Text(
                                    'Automations',
                                    style: TextStyle(
                                        color: Color(0xFFF1F5F9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                    ),
                                ),
                            ],
                        ),
                    ],
                    IconButton(
                        icon: Icon(
                            isExpanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                            size: 20,
                        ),
                        color: const Color(0xFF94A3B8),
                        onPressed: onToggleExpand,
                        tooltip: isExpanded ? 'Collapse automations' : 'Expand automations',
                        splashRadius: 18,
                    ),
                ],
            ),
        );
    }
}
