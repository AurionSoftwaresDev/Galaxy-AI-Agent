import 'package:flutter/material.dart';

/// Neon color theme presets for Galaxy AI.
enum NeonThemePalette {
    obsidianPurple(
        name: 'Obsidian & Neon Purple',
        primary: Color(0xFFA855F7),
        secondary: Color(0xFF6366F1),
        accent: Color(0xFFEC4899),
        background: Color(0xFF070512),
        surface: Color(0xFF0F0B24),
    ),
    deepElectricBlue(
        name: 'Deep Electric Blue',
        primary: Color(0xFF38BDF8),
        secondary: Color(0xFF2563EB),
        accent: Color(0xFF06B6D4),
        background: Color(0xFF040A1A),
        surface: Color(0xFF09142C),
    ),
    cyberNeon(
        name: 'Cyber Mint & Violet',
        primary: Color(0xFF10B981),
        secondary: Color(0xFF8B5CF6),
        accent: Color(0xFFF59E0B),
        background: Color(0xFF050D14),
        surface: Color(0xFF0B1924),
    );

    final String name;
    final Color primary;
    final Color secondary;
    final Color accent;
    final Color background;
    final Color surface;

    const NeonThemePalette({
        required this.name,
        required this.primary,
        required this.secondary,
        required this.accent,
        required this.background,
        required this.surface,
    });
}

/// Agent configuration parameters managed through the Settings window.
class AgentConfig {
    final String model;
    final String voicePersona;
    final double temperature;
    final double speechRate;
    final double pitch;
    final bool autoListen;
    final bool toolWebSearch;
    final bool toolCodeInterpreter;
    final bool toolDiagnostics;
    final bool toolCalendar;
    final NeonThemePalette themePalette;
    final int dotDensity;
    final bool backgroundOrbsEnabled;
    final String backendWsUrl;

    const AgentConfig({
        this.model = 'Gemini 2.5 Flash',
        this.voicePersona = 'Aoede (Warm & Intelligent)',
        this.temperature = 0.7,
        this.speechRate = 1.05,
        this.pitch = 1.0,
        this.autoListen = true,
        this.toolWebSearch = true,
        this.toolCodeInterpreter = true,
        this.toolDiagnostics = true,
        this.toolCalendar = true,
        this.themePalette = NeonThemePalette.obsidianPurple,
        this.dotDensity = 140,
        this.backgroundOrbsEnabled = true,
        this.backendWsUrl = 'ws://127.0.0.1:8080/ws',
    });

    AgentConfig copyWith({
        String? model,
        String? voicePersona,
        double? temperature,
        double? speechRate,
        double? pitch,
        bool? autoListen,
        bool? toolWebSearch,
        bool? toolCodeInterpreter,
        bool? toolDiagnostics,
        bool? toolCalendar,
        NeonThemePalette? themePalette,
        int? dotDensity,
        bool? backgroundOrbsEnabled,
        String? backendWsUrl,
    }) {
        return AgentConfig(
            model: model ?? this.model,
            voicePersona: voicePersona ?? this.voicePersona,
            temperature: temperature ?? this.temperature,
            speechRate: speechRate ?? this.speechRate,
            pitch: pitch ?? this.pitch,
            autoListen: autoListen ?? this.autoListen,
            toolWebSearch: toolWebSearch ?? this.toolWebSearch,
            toolCodeInterpreter: toolCodeInterpreter ?? this.toolCodeInterpreter,
            toolDiagnostics: toolDiagnostics ?? this.toolDiagnostics,
            toolCalendar: toolCalendar ?? this.toolCalendar,
            themePalette: themePalette ?? this.themePalette,
            dotDensity: dotDensity ?? this.dotDensity,
            backgroundOrbsEnabled: backgroundOrbsEnabled ?? this.backgroundOrbsEnabled,
            backendWsUrl: backendWsUrl ?? this.backendWsUrl,
        );
    }
}
