import 'package:flutter/material.dart';

/// Task automation item definition for Galaxy AI.
class AutomationTask {
    final String id;
    final String title;
    final String description;
    final IconData icon;
    final Color accentColor;
    final String prompt;
    final String toolName;

    const AutomationTask({
        required this.id,
        required this.title,
        required this.description,
        required this.icon,
        required this.accentColor,
        required this.prompt,
        required this.toolName,
    });
}

/// Default built-in automation tasks available in the Galaxy AI sidebar.
const List<AutomationTask> defaultAutomationTasks = [
    AutomationTask(
        id: 'clipboard_summary',
        title: 'Summarize Clipboard',
        description: 'Extract key points and action items',
        icon: Icons.content_paste_search_rounded,
        accentColor: Color(0xFF38BDF8),
        prompt: 'Please read my active clipboard buffer, extract key highlights, and outline 3 critical next actions.',
        toolName: 'clipboard_extractor',
    ),
    AutomationTask(
        id: 'system_diagnostics',
        title: 'System Diagnostics',
        description: 'CPU, memory, latency & health check',
        icon: Icons.speed_rounded,
        accentColor: Color(0xFF10B981),
        prompt: 'Run full desktop system diagnostics: inspect latency, audio buffer health, and LLM throughput.',
        toolName: 'diagnostics_runner',
    ),
    AutomationTask(
        id: 'draft_email',
        title: 'Draft Project Update',
        description: 'Compose executive briefing email',
        icon: Icons.mark_email_read_outlined,
        accentColor: Color(0xFFA855F7),
        prompt: 'Draft a crisp executive email update for leadership highlighting sprint milestones and blocker resolutions.',
        toolName: 'email_composer',
    ),
    AutomationTask(
        id: 'web_research',
        title: 'Deep Web Research',
        description: 'Live multi-source synthesis',
        icon: Icons.travel_explore_rounded,
        accentColor: Color(0xFFF59E0B),
        prompt: 'Perform web research on latest multi-modal voice model benchmarks and summarize architectural tradeoffs.',
        toolName: 'web_search',
    ),
    AutomationTask(
        id: 'translate',
        title: 'Translate Context',
        description: 'Convert recent speech to Spanish/German',
        icon: Icons.translate_rounded,
        accentColor: Color(0xFFEC4899),
        prompt: 'Translate the latest conversation summary into Spanish and German with natural tone formatting.',
        toolName: 'polyglot_translator',
    ),
    AutomationTask(
        id: 'calendar_schedule',
        title: 'Schedule Follow-up',
        description: 'Create calendar event with agenda',
        icon: Icons.event_available_rounded,
        accentColor: Color(0xFF6366F1),
        prompt: 'Schedule a 30-minute sync for tomorrow at 2:00 PM with the team including agenda points.',
        toolName: 'calendar_sync',
    ),
    AutomationTask(
        id: 'clear_memory',
        title: 'Flush Context Memory',
        description: 'Reset agent working memory tokens',
        icon: Icons.cleaning_services_rounded,
        accentColor: Color(0xFFEF4444),
        prompt: 'Clear transient context buffer while preserving user profile preferences.',
        toolName: 'memory_sanitizer',
    ),
];
