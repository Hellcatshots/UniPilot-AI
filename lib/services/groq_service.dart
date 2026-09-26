import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  String apiKey = const String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  // Use openai/gpt-oss-20b by default: 8,000 tokens/min limit (vs 1,000 for Qwen)
  String model = 'openai/gpt-oss-20b';

  static const List<String> availableModels = [
    'openai/gpt-oss-20b',
    'openai/gpt-oss-120b',
    'allam-2-7b',
    'qwen/qwen3.8-27b',
  ];

  bool get hasValidKey => apiKey.trim().isNotEmpty && apiKey.trim().startsWith('gsk_');

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString('groq_api_key');
      if (savedKey != null && savedKey.trim().isNotEmpty) {
        apiKey = savedKey.trim();
      }
      final savedModel = prefs.getString('groq_model');
      if (savedModel != null && savedModel.trim().isNotEmpty) {
        model = savedModel.trim();
      }
    } catch (_) {}
  }

  Future<void> updateCredentials({required String newKey, String? newModel}) async {
    apiKey = newKey.trim();
    if (newModel != null && newModel.isNotEmpty) {
      model = newModel.trim();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('groq_api_key', apiKey);
      await prefs.setString('groq_model', model);
    } catch (_) {}
  }

  /// Generate non-streaming response with automatic model fallback
  Future<String> generate({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.5,
    int maxTokens = 1500,
  }) async {
    if (!hasValidKey) {
      return '__EDGE_FAILOVER__';
    }

    final candidateModels = [
      model,
      ...availableModels.where((m) => m != model),
    ];

    for (final candidate in candidateModels) {
      try {
        final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
        final headers = {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'User-Agent': 'UniPilot/1.0',
        };

        final body = jsonEncode({
          'model': candidate,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
        });

        final response = await http.post(uri, headers: headers, body: body).timeout(
          const Duration(seconds: 15),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final content = data['choices']?[0]?['message']?['content'] ?? '';
          return content.toString().trim();
        } else if (response.statusCode == 429) {
          debugPrint('Groq 429 rate limit on $candidate, trying next model in pool...');
          continue; // Try next model in pool
        } else {
          debugPrint('Groq API Error (${response.statusCode}): ${response.body}');
          return '__EDGE_FAILOVER__';
        }
      } catch (e) {
        debugPrint('GroqService error on $candidate: $e');
      }
    }
    return '__EDGE_FAILOVER__';
  }

  /// Generate streaming response with automatic model fallback
  Stream<String> generateStream({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.5,
    int maxTokens = 1500,
  }) async* {
    if (!hasValidKey) {
      yield '__EDGE_FAILOVER__';
      return;
    }

    final candidateModels = [
      model,
      ...availableModels.where((m) => m != model),
    ];

    bool succeeded = false;

    for (final candidate in candidateModels) {
      http.Client? client;
      try {
        client = http.Client();
        final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
        final request = http.Request('POST', uri)
          ..headers['Authorization'] = 'Bearer $apiKey'
          ..headers['Content-Type'] = 'application/json'
          ..headers['Accept'] = 'text/event-stream'
          ..headers['User-Agent'] = 'UniPilot/1.0'
          ..body = jsonEncode({
            'model': candidate,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': temperature,
            'max_tokens': maxTokens,
            'stream': true,
          });

        final response = await client.send(request);

        if (response.statusCode == 429) {
          debugPrint('Groq stream 429 rate limit on $candidate, attempting next model in pool...');
          client.close();
          continue; // Try next candidate
        }

        if (response.statusCode != 200) {
          final errBody = await response.stream.bytesToString();
          debugPrint('Groq API stream Error (${response.statusCode}): $errBody');
          client.close();
          yield '__EDGE_FAILOVER__';
          return;
        }

        final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

        await for (final line in stream) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          if (trimmed == 'data: [DONE]') {
            succeeded = true;
            break;
          }
          if (trimmed.startsWith('data: ')) {
            final jsonStr = trimmed.substring(6);
            try {
              final parsed = jsonDecode(jsonStr);
              final delta = parsed['choices']?[0]?['delta']?['content'];
              if (delta != null && delta is String) {
                succeeded = true;
                yield delta;
              }
            } catch (_) {}
          }
        }

        if (succeeded) {
          client.close();
          return;
        }
      } catch (e) {
        debugPrint('GroqService stream error on $candidate: $e');
      } finally {
        client?.close();
      }
    }

    if (!succeeded) {
      yield '__EDGE_FAILOVER__';
    }
  }
}
