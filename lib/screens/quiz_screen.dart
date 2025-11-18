import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late Future<List<Question>> _futureQuestions;
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _futureQuestions = ApiService.fetchQuestions();
  }

  void _submitAnswer(String answer) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selected = answer;
      if (answer == _questions[_currentIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _next() {
    if (!_answered) return;
    if (_currentIndex + 1 >= _questions.length) {
      // finished
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: _score, total: _questions.length),
        ),
      );
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _selected = '';
    });
  }

  Widget _buildOption(String option) {
    final correct = _questions[_currentIndex].correctAnswer;
    Color? color;
    if (!_answered) {
      color = null;
    } else {
      if (option == correct) {
        color = Colors.green[700];
      } else if (option == _selected) {
        color = Colors.red[700];
      } else {
        color = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _submitAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(option, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildQuiz(List<Question> questions) {
    _questions = questions;
    final q = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia Quiz'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('Score: $_score', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(q.question, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            ...q.options.map(_buildOption),
            const Spacer(),
            if (_answered)
              Column(
                children: [
                  Text(
                    _selected == q.correctAnswer
                        ? 'Correct!'
                        : 'Wrong. Answer: ${q.correctAnswer}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selected == q.correctAnswer
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _currentIndex + 1 >= _questions.length
                          ? 'See Results'
                          : 'Next Question',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildError(Object error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia Quiz')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error loading questions:\n$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureQuestions = ApiService.fetchQuestions();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: _futureQuestions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return _buildLoading();
        if (snapshot.hasError) return _buildError(snapshot.error!);
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildError('No questions returned');
        }
        return _buildQuiz(snapshot.data!);
      },
    );
  }
}
