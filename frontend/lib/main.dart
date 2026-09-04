import 'package:flutter/material.dart';

void main() {
  runApp(const AIAgent());
}

class AIAgent extends StatelessWidget {
  const AIAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galaxy AI Agent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const AgentHomePage(),
    );
  }
}

class AgentHomePage extends StatelessWidget {

  const AgentHomePage({super.key});
  
  @override
  Widget build(BuildContext context) {

	return Container();
  }
}