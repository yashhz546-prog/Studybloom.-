import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../services/score_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_ring.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.score});
  final int score;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.score > 90) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = ScoreCalculator.feedbackFor(widget.score);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Day')),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProgressRing(
                      progress: widget.score / 100,
                      centerLabel: '⭐ ${widget.score}',
                      centerSubLabel: '/ 100',
                      size: 200,
                      strokeWidth: 16,
                    ),
                    const SizedBox(height: 32),
                    Text(feedback.emoji, style: const TextStyle(fontSize: 44)),
                    const SizedBox(height: 8),
                    Text(
                      feedback.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.mutedText, fontSize: 15),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to Today'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 12,
              minBlastForce: 6,
              numberOfParticles: 24,
              gravity: 0.25,
              shouldLoop: false,
              colors: const [
                AppColors.rosePink,
                AppColors.softBlush,
                AppColors.primaryPink,
                Colors.white,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
