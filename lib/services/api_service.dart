import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  // You can optionally parameterize these
  static const String _baseUrl = 'https://opentdb.com/api.php';
  static Future<List<Question>> fetchQuestions({
    int amount = 10,
    int category = 9, // General Knowledge
    String difficulty = 'easy',
    String type = 'multiple',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?amount=$amount&category=$category&difficulty=$difficulty&type=$type',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch questions: ${response.statusCode}');
    }
  }
}
