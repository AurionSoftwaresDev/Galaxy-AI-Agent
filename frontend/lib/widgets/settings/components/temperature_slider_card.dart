import 'package:flutter/material.dart';

/// Card component inside SettingsDialog for adjusting the agent LLM temperature
/// (`/settings/change-agent-temperature`).
class TemperatureSliderCard extends StatelessWidget {
    final double temperature;
    final ValueChanged<double> onChanged;
    final ValueChanged<double> onChangeEnd;

    const TemperatureSliderCard({
        super.key,
        required this.temperature,
        required this.onChanged,
        required this.onChangeEnd,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Text(
                            'Agent Temperature',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                            ),
                        ),
                        Text(
                            temperature.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF22D3EE),
                            ),
                        ),
                    ],
                ),
                SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF06B6D4),
                        inactiveTrackColor: const Color(0xFF1E293B),
                        thumbColor: const Color(0xFF22D3EE),
                    ),
                    child: Slider(
                        value: temperature.clamp(0.0, 1.0),
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        onChanged: onChanged,
                        onChangeEnd: onChangeEnd,
                    ),
                ),
            ],
        );
    }
}
