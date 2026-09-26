import 'package:flutter/material.dart';

import '../state/assistant_controller.dart';

/// Minimal dark glassmorphic dialog for configuring the backend `/settings/*` endpoints:
/// - `GET /settings/avaliable-providers`
/// - `GET /settings/avaliable-models`
/// - `PATCH /settings/change-agent-provider`
/// - `PATCH /settings/change-agent-temperature`
class SettingsDialog extends StatefulWidget {
    final AssistantController controller;

    const SettingsDialog({
        super.key,
        required this.controller,
    });

    @override
    State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
    late final TextEditingController _baseUrlController;
    late final TextEditingController _voicePromptController;
    late double _temperature;
    String? _selectedProvider;
    bool _isSaving = false;

    @override
    void initState() {
        super.initState();
        _baseUrlController = TextEditingController(
            text: widget.controller.backendBaseUrl,
        );
        _voicePromptController = TextEditingController();
        _temperature = widget.controller.settings.temperature;
        _selectedProvider = widget.controller.settings.activeProvider;
        widget.controller.refreshAgentSettings();
    }

    @override
    void dispose() {
        _baseUrlController.dispose();
        _voicePromptController.dispose();
        super.dispose();
    }

    Future<void> _handleProviderChanged(String? nextProvider) async {
        if (nextProvider == null || nextProvider == _selectedProvider) return;
        setState(() {
            _selectedProvider = nextProvider;
            _isSaving = true;
        });
        await widget.controller.changeProvider(nextProvider);
        if (mounted) {
            setState(() => _isSaving = false);
        }
    }

    Future<void> _handleTemperatureCommitted(double value) async {
        setState(() => _isSaving = true);
        await widget.controller.changeTemperature(value);
        if (mounted) {
            setState(() => _isSaving = false);
        }
    }

    Future<void> _handleSendPrompt() async {
        final text = _voicePromptController.text.trim();
        if (text.isEmpty) return;
        _voicePromptController.clear();
        Navigator.of(context).pop();
        await widget.controller.sendVoicePrompt(text);
    }

    @override
    Widget build(BuildContext context) {
        return Dialog(
            backgroundColor: const Color(0xFF0B0E17),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF1E293B)),
            ),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedBuilder(
                        animation: widget.controller,
                        builder: (context, _) {
                            final settings = widget.controller.settings;
                            final providers = settings.availableProviders;
                            final models = settings.availableModels;

                            return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                            const Text(
                                                'Galaxy AI Backend Settings',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFF8FAFC),
                                                ),
                                            ),
                                            IconButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                icon: const Icon(
                                                    Icons.close_rounded,
                                                    size: 18,
                                                    color: Color(0xFF64748B),
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                    minWidth: 28,
                                                    minHeight: 28,
                                                ),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 18),

                                    // 1. Server Host URL (`http://127.0.0.1:8000`)
                                    const Text(
                                        'FastAPI Server Endpoint',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                        children: [
                                            Expanded(
                                                child: TextField(
                                                    controller: _baseUrlController,
                                                    style: const TextStyle(
                                                        fontSize: 12.5,
                                                        color: Color(0xFFF1F5F9),
                                                    ),
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            const Color(0xFF111827),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            borderSide:
                                                                const BorderSide(
                                                                color: Color(0xFF1E293B),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                                onPressed: () {
                                                    widget.controller
                                                        .updateBackendBaseUrl(
                                                        _baseUrlController.text,
                                                    );
                                                },
                                                style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFF22D3EE),
                                                ),
                                                child: const Text(
                                                    'Connect',
                                                    style: TextStyle(fontSize: 12),
                                                ),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 18),

                                    // 2. LLM Provider Selector (`/settings/change-agent-provider`)
                                    const Text(
                                        'LLM Provider (/settings/change-agent-provider)',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF111827),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: const Color(0xFF1E293B),
                                            ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                                value: providers.contains(_selectedProvider)
                                                    ? _selectedProvider
                                                    : (providers.isNotEmpty
                                                        ? providers.first
                                                        : null),
                                                isExpanded: true,
                                                dropdownColor:
                                                    const Color(0xFF111827),
                                                hint: const Text(
                                                    'Connect backend to load providers',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF64748B),
                                                    ),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: Color(0xFFF1F5F9),
                                                ),
                                                items: providers
                                                    .map(
                                                        (provider) =>
                                                            DropdownMenuItem<String>(
                                                            value: provider,
                                                            child: Text(provider),
                                                        ),
                                                    )
                                                    .toList(),
                                                onChanged: _isSaving
                                                    ? null
                                                    : _handleProviderChanged,
                                            ),
                                        ),
                                    ),

                                    if (models.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                            'Configured Models: ${models.join(' · ')}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                            ),
                                        ),
                                    ],
                                    const SizedBox(height: 18),

                                    // 3. Temperature Slider (`/settings/change-agent-temperature`)
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                            const Text(
                                                'Agent Temperature',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF94A3B8),
                                                ),
                                            ),
                                            Text(
                                                _temperature.toStringAsFixed(2),
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
                                            activeTrackColor:
                                                const Color(0xFF06B6D4),
                                            inactiveTrackColor:
                                                const Color(0xFF1E293B),
                                            thumbColor: const Color(0xFF22D3EE),
                                        ),
                                        child: Slider(
                                            value: _temperature.clamp(0.0, 1.0),
                                            min: 0.0,
                                            max: 1.0,
                                            divisions: 20,
                                            onChanged: (val) =>
                                                setState(() => _temperature = val),
                                            onChangeEnd: _handleTemperatureCommitted,
                                        ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 4. Direct Voice Utterance Dispatch (`/ws/assistant` or `/agent/generate`)
                                    const Text(
                                        'Dispatch Utterance to /ws/assistant',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                        children: [
                                            Expanded(
                                                child: TextField(
                                                    controller:
                                                        _voicePromptController,
                                                    onSubmitted: (_) =>
                                                        _handleSendPrompt(),
                                                    style: const TextStyle(
                                                        fontSize: 12.5,
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
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            const Color(0xFF111827),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            borderSide:
                                                                const BorderSide(
                                                                color: Color(0xFF1E293B),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                                onPressed: _handleSendPrompt,
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF06B6D4),
                                                    foregroundColor:
                                                        const Color(0xFF07090E),
                                                    padding:
                                                        const EdgeInsets.symmetric(
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
                        },
                    ),
                ),
            ),
        );
    }
}
