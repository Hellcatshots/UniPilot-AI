import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hybrid_ai_service.dart';
import '../theme/app_theme.dart';

class EngineStatusChip extends StatelessWidget {
  const EngineStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAiService>(
      builder: (context, aiService, child) {
        final isCloud = aiService.isCloudBoost;
        final activeColor = isCloud ? AppTheme.primaryViolet : AppTheme.emeraldGreen;
        final icon = isCloud ? Icons.bolt_rounded : Icons.offline_bolt_rounded;

        return Tooltip(
          message: 'Click to toggle between On-Device Edge and Cloud Boost LPU',
          child: InkWell(
            onTap: () {
              aiService.toggleEngineMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppTheme.cardSurfaceLight,
                  content: Row(
                    children: [
                      Icon(icon, color: activeColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        isCloud
                            ? 'Switched to ⚡ On-Device Edge Mode (Offline, ₹0 Cost)'
                            : 'Switched to 🚀 Cloud Boost Mode (Groq LPU 500 T/s)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: activeColor.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: activeColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isCloud ? 'Cloud Boost (Groq LPU)' : 'Edge AI (Offline)',
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.swap_horiz_rounded, color: activeColor.withValues(alpha: 0.7), size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
