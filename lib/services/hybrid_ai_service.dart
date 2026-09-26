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

  AiEngineMode _currentMode = AiEngineMode.cloudBoost; // Default to Cloud Boost, auto-fallback to Edge if no key

  AiEngineMode get currentMode => _currentMode;
  bool get isCloudBoost => _currentMode == AiEngineMode.cloudBoost;
  bool get isEdgeOffline => _currentMode == AiEngineMode.edgeOffline;

  String get activeEngineLabel {
    if (isCloudBoost && _groq.hasValidKey) {
      return '🚀 Cloud Boost: Groq LPU (${_groq.model})';
    }
    return '⚡ Edge-First: On-Device / Offline (₹0 Cost)';
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

  /// Master streaming dispatch with zero-drop failover
  Stream<String> generateStream({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.5,
    int maxTokens = 1500,
  }) async* {
    // If Cloud Boost is requested but no key is configured, seamlessly execute Edge engine
    if (isCloudBoost && !_groq.hasValidKey) {
      yield* _localLlm.generateStream(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        temperature: temperature,
        maxTokens: maxTokens,
      );
      return;
    }

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
          if (chunk.contains('__EDGE_FAILOVER__') ||
              chunk.contains('__RATE_LIMIT_429__') ||
              chunk.contains('Groq API Error') ||
              chunk.contains('invalid_api_key') ||
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
