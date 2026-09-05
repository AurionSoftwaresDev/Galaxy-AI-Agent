import 'package:flutter/material.dart';
import 'api/backend_client.dart';
import 'screens/main_screen.dart';
import 'services/audio_service.dart';
import 'services/connection_service.dart';
import 'state/assistant_controller.dart';

/// Application entry point for Galaxy AI Flutter Desktop.
void main() {
    WidgetsFlutterBinding.ensureInitialized();

    // Instantiate modular services
    final backendClient = FastApiBackendClient();
    final audioService = DesktopAudioService();
    final connectionService = ConnectionService(client: backendClient);

    // Instantiate central controller
    final assistantController = AssistantController(
        backendClient: backendClient,
        audioService: audioService,
        connectionService: connectionService,
    );

    // Boot voice interaction flow on startup
    assistantController.initialize();

    runApp(GalaxyAiApp(controller: assistantController));
}

/// Root widget for the Galaxy AI Desktop application.
class GalaxyAiApp extends StatefulWidget {
    final AssistantController controller;

    const GalaxyAiApp({
        super.key,
        required this.controller,
    });

    @override
    State<GalaxyAiApp> createState() => _GalaxyAiAppState();
}

class _GalaxyAiAppState extends State<GalaxyAiApp> {
    @override
    void dispose() {
        widget.controller.dispose();
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
                scaffoldBackgroundColor: const Color(0xFF070B14),
                colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF38BDF8),
                    secondary: Color(0xFF6366F1),
                    surface: Color(0xFF0F172A),
                ),
                fontFamily: 'SF Pro Display',
                useMaterial3: true,
            ),
            home: MainScreen(controller: widget.controller),
        );
    }
}
