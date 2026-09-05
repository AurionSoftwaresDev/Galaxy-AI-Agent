import 'package:flutter/material.dart';
import '../../models/agent_config.dart';
import 'settings_controls.dart';

/// Neon Theme & Visuals tab in Settings window.
class AppearanceTab extends StatelessWidget {
    final NeonThemePalette selectedPalette;
    final int dotDensity;
    final bool backgroundOrbsEnabled;
    final ValueChanged<NeonThemePalette> onPaletteChanged;
    final ValueChanged<int> onDotDensityChanged;
    final ValueChanged<bool> onBackgroundOrbsChanged;

    const AppearanceTab({
        super.key,
        required this.selectedPalette,
        required this.dotDensity,
        required this.backgroundOrbsEnabled,
        required this.onPaletteChanged,
        required this.onDotDensityChanged,
        required this.onBackgroundOrbsChanged,
    });

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        'Select Neon Aesthetic Palette',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Theme Cards
                    Column(
                        children: NeonThemePalette.values.map((palette) {
                            final isSelected = selectedPalette == palette;
                            return InkWell(
                                onTap: () => onPaletteChanged(palette),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: isSelected
                                            ? palette.primary.withValues(alpha: 0.15)
                                            : const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: isSelected ? palette.primary : const Color(0xFF1E293B),
                                            width: isSelected ? 1.8 : 1.0,
                                        ),
                                    ),
                                    child: Row(
                                        children: [
                                            // Color Swatches
                                            Row(
                                                children: [
                                                    ColorSwatchCircle(color: palette.primary),
                                                    const SizedBox(width: 4),
                                                    ColorSwatchCircle(color: palette.secondary),
                                                    const SizedBox(width: 4),
                                                    ColorSwatchCircle(color: palette.accent),
                                                ],
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                                child: Text(
                                                    palette.name,
                                                    style: TextStyle(
                                                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                                        fontSize: 13,
                                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                    ),
                                                ),
                                            ),
                                            if (isSelected)
                                                Icon(Icons.check_circle_rounded, size: 18, color: palette.primary),
                                        ],
                                    ),
                                ),
                            );
                        }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Particle / Dots Density
                    SettingsSlider(
                        label: 'Speaker Circle Dots & Particle Density',
                        value: dotDensity.toDouble(),
                        min: 40,
                        max: 200,
                        displayValue: '$dotDensity particles',
                        onChanged: (val) => onDotDensityChanged(val.round()),
                    ),

                    const SizedBox(height: 16),

                    // Background Orbs Toggle
                    SettingsSwitchRow(
                        title: 'Ambient Floating Background Orbs',
                        subtitle: 'Smooth trigonometric neon orbs in background',
                        value: backgroundOrbsEnabled,
                        onChanged: onBackgroundOrbsChanged,
                    ),
                ],
            ),
        );
    }
}
