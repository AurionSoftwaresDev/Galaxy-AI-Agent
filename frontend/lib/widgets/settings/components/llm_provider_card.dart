import 'package:flutter/material.dart';

/// Card component inside SettingsDialog for selecting the active LLM Provider
/// (`/settings/change-agent-provider`) and viewing configured models.
class LlmProviderCard extends StatelessWidget {
    final List<String> providers;
    final List<String> models;
    final String? selectedProvider;
    final bool isSaving;
    final ValueChanged<String?> onProviderChanged;

    const LlmProviderCard({
        super.key,
        required this.providers,
        required this.models,
        required this.selectedProvider,
        required this.isSaving,
        required this.onProviderChanged,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            value: providers.contains(selectedProvider)
                                ? selectedProvider
                                : (providers.isNotEmpty
                                    ? providers.first
                                    : null),
                            isExpanded: true,
                            dropdownColor: const Color(0xFF111827),
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
                                    (provider) => DropdownMenuItem<String>(
                                        value: provider,
                                        child: Text(provider),
                                    ),
                                )
                                .toList(),
                            onChanged: isSaving ? null : onProviderChanged,
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
            ],
        );
    }
}
