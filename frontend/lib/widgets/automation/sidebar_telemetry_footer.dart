import 'package:flutter/material.dart';

/// Telemetry resource monitor rendered at the bottom of the expanded automation sidebar.
class SidebarTelemetryFooter extends StatelessWidget {
    const SidebarTelemetryFooter({super.key});

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B), width: 1),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Row(
                        children: [
                            Icon(Icons.hub_outlined, size: 12, color: Color(0xFF38BDF8)),
                            SizedBox(width: 6),
                            Text(
                                'Engine Telemetry',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 6),
                    _buildTelemetryRow('Latency', '14 ms'),
                    _buildTelemetryRow('Throughput', '48 tok/s'),
                    _buildTelemetryRow('Memory', '24 MB'),
                ],
            ),
        );
    }

    Widget _buildTelemetryRow(String label, String value) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                        label,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                    ),
                    Text(
                        value,
                        style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ],
            ),
        );
    }
}
