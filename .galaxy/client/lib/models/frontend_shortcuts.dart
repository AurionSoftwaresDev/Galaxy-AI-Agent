import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Existing frontend-only keyboard shortcut actions.
enum FrontendShortcutAction {
    toggleVoiceInteraction,
    toggleMute,
    interruptAssistant,
    reconnect;

    String get label {
        switch (this) {
            case FrontendShortcutAction.toggleVoiceInteraction:
                return 'Toggle Voice / Orb';
            case FrontendShortcutAction.toggleMute:
                return 'Mute / Unmute Mic';
            case FrontendShortcutAction.interruptAssistant:
                return 'Interrupt Speech';
            case FrontendShortcutAction.reconnect:
                return 'Reconnect Backend';
        }
    }

    String get description {
        switch (this) {
            case FrontendShortcutAction.toggleVoiceInteraction:
                return 'Listen, mute, or interrupt';
            case FrontendShortcutAction.toggleMute:
                return 'Toggle microphone mute';
            case FrontendShortcutAction.interruptAssistant:
                return 'Stop speaking immediately';
            case FrontendShortcutAction.reconnect:
                return 'Reconnect to server';
        }
    }
}

/// Frontend-only keyboard shortcuts configuration for the 4 existing UI shortcuts.
@immutable
class FrontendShortcutsConfig {
    final Map<FrontendShortcutAction, LogicalKeyboardKey> bindings;

    const FrontendShortcutsConfig({
        required this.bindings,
    });

    factory FrontendShortcutsConfig.defaults() {
        return const FrontendShortcutsConfig(
            bindings: {
                FrontendShortcutAction.toggleVoiceInteraction:
                    LogicalKeyboardKey.space,
                FrontendShortcutAction.toggleMute: LogicalKeyboardKey.keyM,
                FrontendShortcutAction.interruptAssistant:
                    LogicalKeyboardKey.escape,
                FrontendShortcutAction.reconnect: LogicalKeyboardKey.keyR,
            },
        );
    }

    LogicalKeyboardKey keyFor(FrontendShortcutAction action) {
        return bindings[action] ??
            FrontendShortcutsConfig.defaults().bindings[action]!;
    }

    String labelFor(FrontendShortcutAction action) {
        return formatKeyLabel(keyFor(action));
    }

    bool matches(FrontendShortcutAction action, LogicalKeyboardKey pressedKey) {
        final bound = keyFor(action);
        if (bound == pressedKey) {
            return true;
        }
        final boundLabel = formatKeyLabel(bound).toUpperCase();
        final pressedLabel = formatKeyLabel(pressedKey).toUpperCase();
        return boundLabel.isNotEmpty && boundLabel == pressedLabel;
    }

    FrontendShortcutsConfig copyWithBinding(
        FrontendShortcutAction action,
        LogicalKeyboardKey newKey,
    ) {
        final next = Map<FrontendShortcutAction, LogicalKeyboardKey>.from(
            bindings,
        );
        final previousKey = next[action];
        // If another action already uses newKey, swap its binding with previousKey
        for (final entry in bindings.entries) {
            if (entry.key != action &&
                formatKeyLabel(entry.value).toUpperCase() ==
                    formatKeyLabel(newKey).toUpperCase() &&
                previousKey != null) {
                next[entry.key] = previousKey;
            }
        }
        next[action] = newKey;
        return FrontendShortcutsConfig(bindings: Map.unmodifiable(next));
    }

    static const List<LogicalKeyboardKey> presetKeys = [
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.keyM,
        LogicalKeyboardKey.escape,
        LogicalKeyboardKey.keyR,
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.tab,
        LogicalKeyboardKey.keyV,
        LogicalKeyboardKey.keyK,
        LogicalKeyboardKey.keyP,
        LogicalKeyboardKey.keyS,
    ];

    String get summaryLabel {
        return '${labelFor(FrontendShortcutAction.toggleVoiceInteraction)} · '
            '${labelFor(FrontendShortcutAction.toggleMute)} · '
            '${labelFor(FrontendShortcutAction.interruptAssistant)} · '
            '${labelFor(FrontendShortcutAction.reconnect)}';
    }

    static bool isModifierKey(LogicalKeyboardKey key) {
        return key == LogicalKeyboardKey.shiftLeft ||
            key == LogicalKeyboardKey.shiftRight ||
            key == LogicalKeyboardKey.shift ||
            key == LogicalKeyboardKey.controlLeft ||
            key == LogicalKeyboardKey.controlRight ||
            key == LogicalKeyboardKey.control ||
            key == LogicalKeyboardKey.altLeft ||
            key == LogicalKeyboardKey.altRight ||
            key == LogicalKeyboardKey.alt ||
            key == LogicalKeyboardKey.metaLeft ||
            key == LogicalKeyboardKey.metaRight ||
            key == LogicalKeyboardKey.meta;
    }

    static String formatKeyLabel(LogicalKeyboardKey key) {
        if (key == LogicalKeyboardKey.space) return 'Space';
        if (key == LogicalKeyboardKey.escape) return 'Esc';
        if (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) {
            return 'Enter';
        }
        if (key == LogicalKeyboardKey.tab) return 'Tab';
        if (key == LogicalKeyboardKey.backspace) return 'Backspace';
        if (key == LogicalKeyboardKey.delete) return 'Delete';
        if (key == LogicalKeyboardKey.arrowUp) return 'Up';
        if (key == LogicalKeyboardKey.arrowDown) return 'Down';
        if (key == LogicalKeyboardKey.arrowLeft) return 'Left';
        if (key == LogicalKeyboardKey.arrowRight) return 'Right';

        final label = key.keyLabel.trim();
        if (label.isNotEmpty) {
            return label.length == 1 ? label.toUpperCase() : label;
        }
        final debugName = key.debugName ?? 'Key';
        return debugName.replaceFirst('Key ', '');
    }
}
