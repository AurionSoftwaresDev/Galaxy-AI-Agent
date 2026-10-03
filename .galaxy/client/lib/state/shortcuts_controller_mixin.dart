import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/assistant_state.dart';

/// Mixin providing reactive frontend-only keyboard shortcuts configuration
/// and key-recording state management.
mixin ShortcutsControllerMixin on ChangeNotifier {
    FrontendShortcutsConfig _shortcuts = FrontendShortcutsConfig.defaults();
    FrontendShortcutAction? _recordingShortcutAction;
    String? _shortcutFeedbackMessage;
    bool _isLeftBottomShortcutsExpanded = true;

    FrontendShortcutsConfig get shortcuts => _shortcuts;
    FrontendShortcutAction? get recordingShortcutAction =>
        _recordingShortcutAction;
    bool get isRecordingShortcut => _recordingShortcutAction != null;
    String? get shortcutFeedbackMessage => _shortcutFeedbackMessage;
    bool get isLeftBottomShortcutsExpanded => _isLeftBottomShortcutsExpanded;

    /// Toggles the Left Bottom Side Settings / Keyboard Shortcuts section expanded or collapsed.
    void toggleLeftBottomShortcutsSection() {
        _isLeftBottomShortcutsExpanded = !_isLeftBottomShortcutsExpanded;
        if (!_isLeftBottomShortcutsExpanded) {
            _recordingShortcutAction = null;
        }
        notifyListeners();
    }

    /// Starts or cancels listening for a new key press to rebind a frontend shortcut.
    void setRecordingShortcutAction(
        FrontendShortcutAction? action, {
        bool notify = true,
    }) {
        final nextAction =
            (action != null && _recordingShortcutAction == action)
                ? null
                : action;
        if (_recordingShortcutAction == nextAction &&
            _shortcutFeedbackMessage == null) {
            return;
        }
        _recordingShortcutAction = nextAction;
        if (nextAction != null) {
            _shortcutFeedbackMessage = null;
        }
        if (notify) {
            notifyListeners();
        }
    }

    /// Cancels active shortcut key recording without triggering `notifyListeners()`,
    /// safe to call from widget `dispose()` or dialog teardown.
    void cancelRecordingShortcutSilently() {
        _recordingShortcutAction = null;
    }

    /// Updates a frontend keyboard shortcut binding in the UI without touching the backend.
    void updateShortcut(
        FrontendShortcutAction action,
        LogicalKeyboardKey newKey,
    ) {
        if (FrontendShortcutsConfig.isModifierKey(newKey)) {
            return;
        }
        _shortcuts = _shortcuts.copyWithBinding(action, newKey);
        _recordingShortcutAction = null;
        _shortcutFeedbackMessage =
            'Updated "${action.label}" to [${_shortcuts.labelFor(action)}]';
        notifyListeners();
    }

    /// Resets all frontend keyboard shortcuts to their default bindings (Space, M, Esc, R).
    void resetShortcutsToDefault() {
        _shortcuts = FrontendShortcutsConfig.defaults();
        _recordingShortcutAction = null;
        _shortcutFeedbackMessage = 'Reset all shortcuts to defaults';
        notifyListeners();
    }
}
