import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/agent_config.dart';
import '../models/user_profile.dart';
import 'settings/agent_config_tab.dart';
import 'settings/appearance_tab.dart';
import 'settings/settings_footer.dart';
import 'settings/settings_title_bar.dart';
import 'settings/user_profile_tab.dart';

/// In-window movable, resizable floating Settings & Configuration window.
///
/// Wraps User Profile (Gmail, Username, Avatar with Initials Fallback)
/// and Agent Configurations (Models, Voice, Themes, Permissions).
class SettingsWindow extends StatefulWidget {
    final UserProfile userProfile;
    final AgentConfig agentConfig;
    final void Function(UserProfile) onSaveUserProfile;
    final void Function(AgentConfig) onSaveAgentConfig;
    final VoidCallback onClose;

    const SettingsWindow({
        super.key,
        required this.userProfile,
        required this.agentConfig,
        required this.onSaveUserProfile,
        required this.onSaveAgentConfig,
        required this.onClose,
    });

    @override
    State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> with SingleTickerProviderStateMixin {
    late TabController _tabController;

    // Window position and dimensions
    Offset _position = const Offset(80, 60);
    double _width = 620;
    double _height = 540;
    bool _isMaximized = false;
    Offset _prevPosition = Offset.zero;
    Size _prevSize = Size.zero;

    // User form controllers
    late TextEditingController _usernameController;
    late TextEditingController _emailController;
    late TextEditingController _avatarUrlController;

    // Agent config state
    late String _selectedModel;
    late String _selectedVoice;
    late double _temperature;
    late double _speechRate;
    late double _pitch;
    late bool _autoListen;
    late bool _toolWebSearch;
    late bool _toolCodeInterpreter;
    late bool _toolDiagnostics;
    late bool _toolCalendar;
    late NeonThemePalette _selectedPalette;
    late int _dotDensity;
    late bool _backgroundOrbsEnabled;
    late TextEditingController _wsUrlController;

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 3, vsync: this);

        // Populate initial user fields
        _usernameController = TextEditingController(text: widget.userProfile.username);
        _emailController = TextEditingController(text: widget.userProfile.email);
        _avatarUrlController = TextEditingController(text: widget.userProfile.avatarUrl ?? '');

        // Populate initial agent configs
        _selectedModel = widget.agentConfig.model;
        _selectedVoice = widget.agentConfig.voicePersona;
        _temperature = widget.agentConfig.temperature;
        _speechRate = widget.agentConfig.speechRate;
        _pitch = widget.agentConfig.pitch;
        _autoListen = widget.agentConfig.autoListen;
        _toolWebSearch = widget.agentConfig.toolWebSearch;
        _toolCodeInterpreter = widget.agentConfig.toolCodeInterpreter;
        _toolDiagnostics = widget.agentConfig.toolDiagnostics;
        _toolCalendar = widget.agentConfig.toolCalendar;
        _selectedPalette = widget.agentConfig.themePalette;
        _dotDensity = widget.agentConfig.dotDensity;
        _backgroundOrbsEnabled = widget.agentConfig.backgroundOrbsEnabled;
        _wsUrlController = TextEditingController(text: widget.agentConfig.backendWsUrl);
    }

    @override
    void dispose() {
        _tabController.dispose();
        _usernameController.dispose();
        _emailController.dispose();
        _avatarUrlController.dispose();
        _wsUrlController.dispose();
        super.dispose();
    }

    void _saveAll() {
        final updatedProfile = widget.userProfile.copyWith(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            avatarUrl: _avatarUrlController.text.trim().isEmpty ? null : _avatarUrlController.text.trim(),
        );

        final updatedConfig = widget.agentConfig.copyWith(
            model: _selectedModel,
            voicePersona: _selectedVoice,
            temperature: _temperature,
            speechRate: _speechRate,
            pitch: _pitch,
            autoListen: _autoListen,
            toolWebSearch: _toolWebSearch,
            toolCodeInterpreter: _toolCodeInterpreter,
            toolDiagnostics: _toolDiagnostics,
            toolCalendar: _toolCalendar,
            themePalette: _selectedPalette,
            dotDensity: _dotDensity,
            backgroundOrbsEnabled: _backgroundOrbsEnabled,
            backendWsUrl: _wsUrlController.text.trim(),
        );

        widget.onSaveUserProfile(updatedProfile);
        widget.onSaveAgentConfig(updatedConfig);
        widget.onClose();
    }

    void _toggleMaximize(Size screenSize) {
        setState(() {
            if (_isMaximized) {
                _position = _prevPosition;
                _width = _prevSize.width;
                _height = _prevSize.height;
                _isMaximized = false;
            } else {
                _prevPosition = _position;
                _prevSize = Size(_width, _height);
                _position = const Offset(20, 20);
                _width = screenSize.width - 40;
                _height = screenSize.height - 40;
                _isMaximized = true;
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        final screenSize = MediaQuery.of(context).size;

        final double maxAllowedWidth = math.max(320.0, screenSize.width - 32);
        final double maxAllowedHeight = math.max(280.0, screenSize.height - 32);

        final double safeWidth = _isMaximized
            ? maxAllowedWidth
            : _width.clamp(math.min(420.0, maxAllowedWidth), maxAllowedWidth);
        final double safeHeight = _isMaximized
            ? maxAllowedHeight
            : _height.clamp(math.min(340.0, maxAllowedHeight), maxAllowedHeight);

        final double maxLeft = math.max(0.0, screenSize.width - safeWidth - 16);
        final double maxTop = math.max(0.0, screenSize.height - safeHeight - 16);

        final double safeLeft = _isMaximized ? 16.0 : _position.dx.clamp(0.0, maxLeft);
        final double safeTop = _isMaximized ? 16.0 : _position.dy.clamp(0.0, maxTop);

        return Positioned(
            left: safeLeft,
            top: safeTop,
            width: safeWidth,
            height: safeHeight,
            child: Material(
                elevation: 24,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF090D1A).withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                            width: 1.4,
                        ),
                        boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                                blurRadius: 28,
                                spreadRadius: 4,
                            ),
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.7),
                                blurRadius: 36,
                                offset: const Offset(0, 14),
                            ),
                        ],
                    ),
                    child: Stack(
                        children: [
                            Column(
                                children: [
                                    // 1. Movable Window Title Bar (Drag to move)
                                    SettingsTitleBar(
                                        isMaximized: _isMaximized,
                                        onToggleMaximize: () => _toggleMaximize(screenSize),
                                        onClose: widget.onClose,
                                        onPanUpdate: (details) {
                                            setState(() {
                                                _position = Offset(
                                                    (_position.dx + details.delta.dx).clamp(0.0, maxLeft),
                                                    (_position.dy + details.delta.dy).clamp(0.0, maxTop),
                                                );
                                            });
                                        },
                                    ),

                                    // 2. Tab Navigation
                                    _buildTabBar(),

                                    // 3. Tab Contents
                                    Expanded(
                                        child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                                UserProfileTab(
                                                    usernameController: _usernameController,
                                                    emailController: _emailController,
                                                    avatarUrlController: _avatarUrlController,
                                                    onFieldsChanged: () => setState(() {}),
                                                ),
                                                AgentConfigTab(
                                                    selectedModel: _selectedModel,
                                                    selectedVoice: _selectedVoice,
                                                    temperature: _temperature,
                                                    speechRate: _speechRate,
                                                    autoListen: _autoListen,
                                                    toolWebSearch: _toolWebSearch,
                                                    toolCodeInterpreter: _toolCodeInterpreter,
                                                    toolDiagnostics: _toolDiagnostics,
                                                    wsUrlController: _wsUrlController,
                                                    onModelChanged: (val) => setState(() => _selectedModel = val),
                                                    onVoiceChanged: (val) => setState(() => _selectedVoice = val),
                                                    onTemperatureChanged: (val) => setState(() => _temperature = val),
                                                    onSpeechRateChanged: (val) => setState(() => _speechRate = val),
                                                    onAutoListenChanged: (val) => setState(() => _autoListen = val),
                                                    onToolWebSearchChanged: (val) => setState(() => _toolWebSearch = val),
                                                    onToolCodeInterpreterChanged: (val) => setState(() => _toolCodeInterpreter = val),
                                                    onToolDiagnosticsChanged: (val) => setState(() => _toolDiagnostics = val),
                                                ),
                                                AppearanceTab(
                                                    selectedPalette: _selectedPalette,
                                                    dotDensity: _dotDensity,
                                                    backgroundOrbsEnabled: _backgroundOrbsEnabled,
                                                    onPaletteChanged: (val) => setState(() => _selectedPalette = val),
                                                    onDotDensityChanged: (val) => setState(() => _dotDensity = val),
                                                    onBackgroundOrbsChanged: (val) => setState(() => _backgroundOrbsEnabled = val),
                                                ),
                                            ],
                                        ),
                                    ),

                                    // 4. Window Footer Actions
                                    SettingsFooter(
                                        onCancel: widget.onClose,
                                        onApply: _saveAll,
                                    ),
                                ],
                            ),

                            // 5. Resizable Drag Handle in Bottom Right
                            if (!_isMaximized)
                                Positioned(
                                    right: 0,
                                    bottom: 0,
                                    width: 24,
                                    height: 24,
                                    child: GestureDetector(
                                        onPanUpdate: (details) {
                                            setState(() {
                                                _width = (_width + details.delta.dx)
                                                    .clamp(math.min(420.0, maxAllowedWidth), maxAllowedWidth);
                                                _height = (_height + details.delta.dy)
                                                    .clamp(math.min(340.0, maxAllowedHeight), maxAllowedHeight);
                                            });
                                        },
                                        child: MouseRegion(
                                            cursor: SystemMouseCursors.resizeDownRight,
                                            child: Container(
                                                color: Colors.transparent,
                                                alignment: Alignment.bottomRight,
                                                padding: const EdgeInsets.all(4),
                                                child: const Icon(
                                                    Icons.crop_square_rounded,
                                                    size: 12,
                                                    color: Color(0xFF64748B),
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildTabBar() {
        return Container(
            color: const Color(0xFF090D1C),
            child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFA855F7),
                indicatorWeight: 2.5,
                labelColor: const Color(0xFFE2E8F0),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                    Tab(
                        icon: Icon(Icons.account_circle_outlined, size: 16),
                        text: 'User Profile',
                    ),
                    Tab(
                        icon: Icon(Icons.tune_rounded, size: 16),
                        text: 'Agent Model & Voice',
                    ),
                    Tab(
                        icon: Icon(Icons.palette_outlined, size: 16),
                        text: 'Neon Theme & Visuals',
                    ),
                ],
            ),
        );
    }
}
