import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  const ResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = ((score / total) * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text('Your Score', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 64,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '$score/$total',
                style: const TextStyle(fontSize: 26, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$percent%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // restart by reloading main screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const _RestartWrapper()),
                );
              },
              child: const Text('Play Again'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// small wrapper to reload the quiz screen fresh
class _RestartWrapper extends StatelessWidget {
  const _RestartWrapper();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Restarting...')));
  }
}
