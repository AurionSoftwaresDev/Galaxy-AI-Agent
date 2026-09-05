import 'package:flutter/material.dart';
import 'settings_controls.dart';

/// Agent Core & Model configuration tab in Settings window.
class AgentConfigTab extends StatelessWidget {
    final String selectedModel;
    final String selectedVoice;
    final double temperature;
    final double speechRate;
    final bool autoListen;
    final bool toolWebSearch;
    final bool toolCodeInterpreter;
    final bool toolDiagnostics;
    final TextEditingController wsUrlController;
    final ValueChanged<String> onModelChanged;
    final ValueChanged<String> onVoiceChanged;
    final ValueChanged<double> onTemperatureChanged;
    final ValueChanged<double> onSpeechRateChanged;
    final ValueChanged<bool> onAutoListenChanged;
    final ValueChanged<bool> onToolWebSearchChanged;
    final ValueChanged<bool> onToolCodeInterpreterChanged;
    final ValueChanged<bool> onToolDiagnosticsChanged;

    const AgentConfigTab({
        super.key,
        required this.selectedModel,
        required this.selectedVoice,
        required this.temperature,
        required this.speechRate,
        required this.autoListen,
        required this.toolWebSearch,
        required this.toolCodeInterpreter,
        required this.toolDiagnostics,
        required this.wsUrlController,
        required this.onModelChanged,
        required this.onVoiceChanged,
        required this.onTemperatureChanged,
        required this.onSpeechRateChanged,
        required this.onAutoListenChanged,
        required this.onToolWebSearchChanged,
        required this.onToolCodeInterpreterChanged,
        required this.onToolDiagnosticsChanged,
    });

    static const List<String> availableModels = [
        'Gemini 2.5 Flash',
        'Gemini 2.5 Pro',
        'Claude 3.5 Sonnet',
        'GPT-4o Omnimodal',
    ];

    static const List<String> availableVoices = [
        'Aoede (Warm & Intelligent)',
        'Puck (Playful & Energetic)',
        'Charon (Calm & Deep)',
        'Fenrir (Authoritative)',
        'Kore (Friendly Assistant)',
    ];

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Model Selection
                    const Text(
                        'AI Foundation Model',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                value: selectedModel,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
                                items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (val) {
                                    if (val != null) onModelChanged(val);
                                },
                            ),
                        ),
                    ),

                    const SizedBox(height: 16),

                    // Voice Persona Selection
                    const Text(
                        'Agent Voice Persona',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                value: selectedVoice,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
                                items: availableVoices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                onChanged: (val) {
                                    if (val != null) onVoiceChanged(val);
                                },
                            ),
                        ),
                    ),

                    const SizedBox(height: 16),

                    // Sliders (Temperature, Speech Rate)
                    SettingsSlider(
                        label: 'Reasoning Temperature (Creativity)',
                        value: temperature,
                        min: 0.1,
                        max: 1.0,
                        displayValue: temperature.toStringAsFixed(2),
                        onChanged: onTemperatureChanged,
                    ),

                    const SizedBox(height: 12),

                    SettingsSlider(
                        label: 'Speech Playback Speed',
                        value: speechRate,
                        min: 0.75,
                        max: 1.5,
                        displayValue: '${speechRate.toStringAsFixed(2)}x',
                        onChanged: onSpeechRateChanged,
                    ),

                    const SizedBox(height: 16),

                    // Switches & Tool Permissions
                    const Text(
                        'Desktop Tool Permissions',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    SettingsSwitchRow(
                        title: 'Auto-Listen after response',
                        subtitle: 'Resumes microphone capture automatically',
                        value: autoListen,
                        onChanged: onAutoListenChanged,
                    ),
                    SettingsSwitchRow(
                        title: 'Live Web Research Grounding',
                        subtitle: 'Allows agent to browse external web pages',
                        value: toolWebSearch,
                        onChanged: onToolWebSearchChanged,
                    ),
                    SettingsSwitchRow(
                        title: 'Desktop Shell Code Interpreter',
                        subtitle: 'Execute local python/bash scripts safely',
                        value: toolCodeInterpreter,
                        onChanged: onToolCodeInterpreterChanged,
                    ),
                    SettingsSwitchRow(
                        title: 'Telemetry & System Diagnostics',
                        subtitle: 'Analyze hardware metrics and agent memory',
                        value: toolDiagnostics,
                        onChanged: onToolDiagnosticsChanged,
                    ),

                    const SizedBox(height: 14),

                    // Backend WebSocket URL
                    SettingsInputField(
                        label: 'Backend FastAPI WebSocket URL',
                        controller: wsUrlController,
                        hint: 'ws://127.0.0.1:8080/ws',
                        icon: Icons.link_rounded,
                        onChanged: (_) {},
                    ),
                ],
            ),
        );
    }
}
