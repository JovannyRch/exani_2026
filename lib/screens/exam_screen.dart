import 'package:examen_vial_edomex_app_2025/models/option.dart';
import 'package:examen_vial_edomex_app_2025/services/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class QuestionWithOptions {
  final Question question;
  final List<Option> options;

  QuestionWithOptions({required this.question, required this.options});
}

class ExamScreen extends StatefulWidget {
  final List<Question> allQuestions;

  const ExamScreen({super.key, required this.allQuestions});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<QuestionWithOptions> examQuestions = [];
  Map<int, int> answers = {}; // questionId : optionId
  int currentIndex = 0;
  int totalCorrect = 0;
  List<Option> options = [];
  late Question currentQ;

  late Timer timer;
  int secondsRemaining = 30 * 60; // 30 minutos

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();

    List<Question> questions = List.from(widget.allQuestions)..shuffle();
    questions = questions.take(10).toList();

    examQuestions =
        questions
            .map(
              (q) => QuestionWithOptions(
                question: q,
                options: q.getShuffledOptions(maxOptions: 3),
              ),
            )
            .toList();

    // Iniciar cronómetro
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining == 0) {
        _finishExam();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });

    // Cargar banner publicitario
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd();
    _bannerAd!.load().then((_) {
      setState(() {
        _isBannerAdReady = true;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionId, int optionId) {
    setState(() {
      answers[questionId] = optionId;
    });
  }

  void _finishExam() {
    timer.cancel();

    totalCorrect = 0;
    for (var q in examQuestions) {
      if (answers[q.question.id] == q.question.correctOptionId) {
        totalCorrect++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultsScreen(
              totalCorrect: totalCorrect,
              totalQuestions: examQuestions.length,
            ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    currentQ = examQuestions[currentIndex].question;
    options = examQuestions[currentIndex].options;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Examen de manejo"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                _formatTime(secondsRemaining),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / examQuestions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    "Pregunta ${currentIndex + 1} de ${examQuestions.length}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentQ.text,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ...options.map(
                    (o) => Card(
                      color:
                          answers[currentQ.id] == o.id
                              ? Colors.blueAccent
                              : const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          o.text.replaceAll('[br]', '\n'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () => _selectAnswer(currentQ.id, o.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIndex--;
                      });
                    },
                    child: const Text("Anterior"),
                  ),
                if (currentIndex < examQuestions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIndex++;
                      });
                    },
                    child: const Text("Siguiente"),
                  )
                else
                  ElevatedButton(
                    onPressed: _finishExam,
                    child: const Text("Finalizar"),
                  ),
              ],
            ),
          ),
          // Banner publicitario
          if (_isBannerAdReady && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

// ======= RESULTADOS ========
class ResultsScreen extends StatelessWidget {
  final int totalCorrect;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    bool passed = totalCorrect >= 10;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.cancel,
                    size: 80,
                    color: passed ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    passed ? "¡Aprobado!" : "No aprobado",
                    style: TextStyle(
                      color: passed ? Colors.green : Colors.red,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Respondiste $totalCorrect de $totalQuestions preguntas correctamente.",
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Volver al inicio"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
