// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:galaxy_ai/api/backend_client.dart';
import 'package:galaxy_ai/main.dart';
import 'package:galaxy_ai/services/audio_service.dart';
import 'package:galaxy_ai/services/connection_service.dart';
import 'package:galaxy_ai/state/assistant_controller.dart';

void main() {
  testWidgets('Galaxy AI Desktop App smoke test', (WidgetTester tester) async {
    final client = FastApiBackendClient();
    final audio = DesktopAudioService();
    final connection = ConnectionService(client: client);
    final controller = AssistantController(
      backendClient: client,
      audioService: audio,
      connectionService: connection,
    );

    await tester.pumpWidget(GalaxyAiApp(controller: controller));
    expect(find.text('Galaxy AI'), findsOneWidget);
  });
}
