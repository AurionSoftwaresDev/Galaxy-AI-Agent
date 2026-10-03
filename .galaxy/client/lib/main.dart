import 'package:flutter/material.dart';

import 'api/backend_client.dart';
import 'models/assistant_state.dart';
import 'screens/main_screen.dart';
import 'services/voice_service.dart';
import 'state/assistant_controller.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const GalaxyAiApp());
}

/// Root desktop application widget for Galaxy AI Agent.
class GalaxyAiApp extends StatefulWidget {
    const GalaxyAiApp({super.key});

    @override
    State<GalaxyAiApp> createState() => _GalaxyAiAppState();
}

class _GalaxyAiAppState extends State<GalaxyAiApp> {
    late final AssistantController _assistantController;

    @override
    void initState() {
        super.initState();
        final backendClient = HttpWebSocketBackendClient(
            config: const BackendConfig(
                baseUrl: BackendConfig.defaultBaseUrl,
            ),
        );
        final voiceService = VoiceService();

        _assistantController = AssistantController(
            backendClient: backendClient,
            voiceService: voiceService,
        );

        // Immediately initialize default voice mode and connect to backend on launch.
        _assistantController.initializeDefaultVoiceMode();
    }

    @override
    void dispose() {
        _assistantController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Galaxy AI',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF07090E),
                colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF06B6D4),
                    secondary: Color(0xFF818CF8),
                    surface: Color(0xFF0F172A),
                    error: Color(0xFFF43F5E),
                ),
                useMaterial3: true,
            ),
            home: MainScreen(controller: _assistantController),
        );
    }
}
