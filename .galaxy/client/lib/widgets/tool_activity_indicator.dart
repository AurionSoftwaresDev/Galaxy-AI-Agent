import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Subtle, optional indicator displayed when the backend is executing a tool.
class ToolActivityIndicator extends StatelessWidget {
    final ToolActivity? toolActivity;

    const ToolActivityIndicator({
        super.key,
        required this.toolActivity,
    });

    @override
    Widget build(BuildContext context) {
        final isVisible = toolActivity != null && toolActivity!.isActive;

        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
                return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                        child: child,
                    ),
                );
            },
            child: isVisible
                ? Padding(
                      key: ValueKey<String>(toolActivity!.statusText),
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              const SizedBox(
                                  width: 11,
                                  height: 11,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF818CF8),
                                      ),
                                  ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  toolActivity!.statusText,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                      color: Color(0xFFA5B4FC),
                                  ),
                              ),
                          ],
                      ),
                  )
                : const SizedBox(height: 26),
        );
    }
}
