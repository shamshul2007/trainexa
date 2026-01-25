import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trainexa/openai/openai_config.dart';

class AIService {
  final http.Client _client;
  AIService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> createChatCompletion({
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4o',
    Map<String, dynamic>? responseFormat, // e.g., {"type":"json_object"}
  }) async {
    if (endpoint.isEmpty || apiKey.isEmpty) {
      throw Exception('AI endpoint or API key not configured.');
    }
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json; charset=utf-8',
    };

    final body = {
      'model': model,
      'messages': messages,
      if (responseFormat != null) 'response_format': responseFormat,
      'temperature': 0.7,
    };

    final uri = Uri.parse(endpoint);
    final res = await _client.post(uri, headers: headers, body: utf8.encode(jsonEncode(body)));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('AI error ${res.statusCode}: ${res.body}');
      throw Exception('AI request failed with status ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return data;
  }
}
