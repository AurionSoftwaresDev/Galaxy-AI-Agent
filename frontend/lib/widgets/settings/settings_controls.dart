import 'package:flutter/material.dart';

/// Reusable input field for settings forms with icon and dark neon-styled borders.
class SettingsInputField extends StatelessWidget {
    final String label;
    final TextEditingController controller;
    final String hint;
    final IconData icon;
    final ValueChanged<String>? onChanged;

    const SettingsInputField({
        super.key,
        required this.label,
        required this.controller,
        required this.hint,
        required this.icon,
        this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    label,
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                        children: [
                            Icon(icon, size: 16, color: const Color(0xFF64748B)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: TextField(
                                    controller: controller,
                                    style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
                                    decoration: InputDecoration(
                                        hintText: hint,
                                        hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onChanged: onChanged,
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }
}

/// Reusable slider with numeric/formatted label for settings forms.
class SettingsSlider extends StatelessWidget {
    final String label;
    final double value;
    final double min;
    final double max;
    final String displayValue;
    final ValueChanged<double> onChanged;

    const SettingsSlider({
        super.key,
        required this.label,
        required this.value,
        required this.min,
        required this.max,
        required this.displayValue,
        required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                            label,
                            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Text(
                            displayValue,
                            style: const TextStyle(
                                color: Color(0xFFA855F7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                            ),
                        ),
                    ],
                ),
                SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFA855F7),
                        inactiveTrackColor: const Color(0xFF1E293B),
                        thumbColor: Colors.white,
                        overlayColor: const Color(0xFFA855F7).withValues(alpha: 0.2),
                        trackHeight: 3.5,
                    ),
                    child: Slider(
                        value: value,
                        min: min,
                        max: max,
                        onChanged: onChanged,
                    ),
                ),
            ],
        );
    }
}

/// Reusable switch row with title and explanatory subtitle.
class SettingsSwitchRow extends StatelessWidget {
    final String title;
    final String subtitle;
    final bool value;
    final ValueChanged<bool> onChanged;

    const SettingsSwitchRow({
        super.key,
        required this.title,
        required this.subtitle,
        required this.value,
        required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
                children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    title,
                                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                    subtitle,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                ),
                            ],
                        ),
                    ),
                    Switch(
                        value: value,
                        activeThumbColor: const Color(0xFFA855F7),
                        activeTrackColor: const Color(0xFFA855F7).withValues(alpha: 0.3),
                        inactiveThumbColor: const Color(0xFF64748B),
                        inactiveTrackColor: const Color(0xFF1E293B),
                        onChanged: onChanged,
                    ),
                ],
            ),
        );
    }
}

/// Small glowing color circle swatch for neon palette indicators.
class ColorSwatchCircle extends StatelessWidget {
    final Color color;
    final double size;

    const ColorSwatchCircle({
        super.key,
        required this.color,
        this.size = 16,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
                ],
            ),
        );
    }
}
