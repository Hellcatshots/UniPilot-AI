import 'dart:async';
import 'package:flutter/material.dart';
import 'groq_service.dart';
import 'local_llm_service.dart';

enum AiEngineMode { edgeOffline, cloudBoost }

class HybridAiService extends ChangeNotifier {
  static final HybridAiService _instance = HybridAiService._internal();
  factory HybridAiService() => _instance;
  HybridAiService._internal();

  final GroqService _groq = GroqService();
  final LocalLlmService _localLlm = LocalLlmService();

  AiEngineMode _currentMode = AiEngineMode.cloudBoost; // Default to Cloud Boost for lightning demo

  AiEngineMode get currentMode => _currentMode;
  bool get isCloudBoost => _currentMode == AiEngineMode.cloudBoost;
  bool get isEdgeOffline => _currentMode == AiEngineMode.edgeOffline;

  String get activeEngineLabel {
    return isCloudBoost
        ? '🚀 Cloud Boost: Groq LPU (GPT-OSS-20B)'
        : '⚡ Edge-First: On-Device / Offline (₹0 Cost)';
  }

  void toggleEngineMode() {
    _currentMode = isCloudBoost ? AiEngineMode.edgeOffline : AiEngineMode.cloudBoost;
    notifyListeners();
  }

  void setEngineMode(AiEngineMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  /// Master streaming dispatch with zero-drop rate-limit failover
  Stream<String> generateStream({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.5,
    int maxTokens = 1500,
  }) async* {
    if (isCloudBoost) {
      bool needEdgeFailover = false;
      bool yieldedAnyCloudToken = false;

      try {
        await for (final chunk in _groq.generateStream(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          temperature: temperature,
          maxTokens: maxTokens,
        )) {
          if (chunk.contains('__RATE_LIMIT_429__') ||
              chunk.contains('Groq API Error (429)') ||
              chunk.contains('rate_limit_exceeded')) {
            needEdgeFailover = true;
            break;
          }
          yieldedAnyCloudToken = true;
          yield chunk;
        }
      } catch (e) {
        needEdgeFailover = true;
      }

      if (needEdgeFailover) {
        if (yieldedAnyCloudToken) {
          yield '\n\n';
        }
        yield '> ⚡ **Edge Auto-Failover Active**: Groq LPU rate limit encountered. UniPilot instantly switched to the **On-Device Edge Engine (₹0 Cost / Zero Latency)** to guarantee seamless advising.\n\n';
        yield* _localLlm.generateStream(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          temperature: temperature,
          maxTokens: maxTokens,
        );
      }
    } else {
      yield* _localLlm.generateStream(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    }
  }

  /// Master non-streaming dispatch
  Future<String> generate({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final buffer = StringBuffer();
    await for (final token in generateStream(systemPrompt: systemPrompt, userPrompt: userPrompt)) {
      buffer.write(token);
    }
    return buffer.toString();
  }
}

