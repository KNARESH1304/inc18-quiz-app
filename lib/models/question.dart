import 'dart:math';
import 'package:html_unescape/html_unescape.dart';

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    final correct = unescape.convert(json['correct_answer'] as String);
    final incorrectList = List<String>.from(
      json['incorrect_answers'] as List,
    ).map((s) => unescape.convert(s as String)).toList();

    final options = List<String>.from(incorrectList)..add(correct);
    // shuffle deterministically with random seed
    options.shuffle(Random());

    return Question(
      question: unescape.convert(json['question'] as String),
      options: options,
      correctAnswer: correct,
    );
  }
}
