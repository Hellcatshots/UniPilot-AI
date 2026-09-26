import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/groq_service.dart';
import '../services/hybrid_ai_service.dart';
import '../services/local_llm_service.dart';
import '../theme/app_theme.dart';

class ApiSettingsDialog extends StatefulWidget {
  const ApiSettingsDialog({super.key});

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  late TextEditingController _keyController;
  late TextEditingController _modelController;
  String _localModelPath = 'Checking local storage...';

  @override
  void initState() {
    super.initState();
    final groq = GroqService();
    _keyController = TextEditingController(text: groq.apiKey);
    _modelController = TextEditingController(text: groq.model);
    _checkLocalModel();
  }

  Future<void> _checkLocalModel() async {
    final path = await LocalLlmService().getExistingModelPath();
    if (mounted) {
      setState(() {
        _localModelPath = path != null
            ? '✅ Found on-device: $path'
            : '⚠️ No local GGUF found in AppData (Using Edge Rule Engine)';
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      title: const Row(
        children: [
          Icon(Icons.settings_suggest_rounded, color: AppTheme.neonCyan),
          SizedBox(width: 10),
          Text('Hybrid AI Engine Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edge Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.memory_rounded, color: AppTheme.emeraldGreen, size: 16),
                        SizedBox(width: 6),
                        Text('Edge Inference Subsystem', style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _localModelPath,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cloud Settings
              const Text('Cloud Boost (Groq LPU API Key)', style: TextStyle(color: AppTheme.violetLight, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _keyController,
                obscureText: true,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.cardSurfaceLight,
                  hintText: 'Enter Groq API Key (gsk_...)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Groq Model Identifier', style: TextStyle(color: AppTheme.violetLight, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _modelController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.cardSurfaceLight,
                  hintText: 'openai/gpt-oss-20b or openai/gpt-oss-120b',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.smart_toy_rounded, size: 18, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text('openai/gpt-oss-20b (Recommended)', style: TextStyle(fontSize: 11)),
                    backgroundColor: _modelController.text == 'openai/gpt-oss-20b'
                        ? AppTheme.primaryViolet.withValues(alpha: 0.3)
                        : AppTheme.cardSurfaceLight,
                    onPressed: () {
                      setState(() {
                        _modelController.text = 'openai/gpt-oss-20b';
                      });
                    },
                  ),
                  ActionChip(
                    label: const Text('openai/gpt-oss-120b', style: TextStyle(fontSize: 11)),
                    backgroundColor: AppTheme.cardSurfaceLight,
                    onPressed: () {
                      setState(() {
                        _modelController.text = 'openai/gpt-oss-120b';
                      });
                    },
                  ),
                  ActionChip(
                    label: const Text('allam-2-7b', style: TextStyle(fontSize: 11)),
                    backgroundColor: AppTheme.cardSurfaceLight,
                    onPressed: () {
                      setState(() {
                        _modelController.text = 'allam-2-7b';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '⚡ openai/gpt-oss-20b has an 8,000 tokens/min limit (vs 1,000 on Qwen), preventing 429 rate limit errors.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
        ),
        ElevatedButton(
          onPressed: () async {
            final newKey = _keyController.text.trim();
            await GroqService().updateCredentials(
              newKey: newKey,
              newModel: _modelController.text,
            );
            if (context.mounted) {
              final hybrid = context.read<HybridAiService>();
              if (newKey.startsWith('gsk_')) {
                hybrid.setEngineMode(AiEngineMode.cloudBoost);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings updated successfully!')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryViolet,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
