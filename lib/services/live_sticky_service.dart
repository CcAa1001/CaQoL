import 'dart:convert';

import 'package:http/http.dart' as http;

class LiveStickyService {
  Future<String> fetchSnapshot(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid URL');
    }

    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = response.body.trim();
    if (body.isEmpty) {
      return 'No data returned';
    }

    try {
      final decoded = jsonDecode(body);
      const encoder = JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(decoded);
      return pretty.length > 1200 ? '${pretty.substring(0, 1200)}...' : pretty;
    } catch (_) {
      return body.length > 1200 ? '${body.substring(0, 1200)}...' : body;
    }
  }
}
