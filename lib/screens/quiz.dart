// quiz.dart - Completely rewritten with API integration
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPage extends StatefulWidget {
  final String videoId;
  final String userId;
  final String videoTitle;

  const QuizPage({
    super.key,
    required this.videoId,
    required this.userId,
    required this.videoTitle,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  bool isLoadingTest = true;
  bool isSubmittingAnswer = false;
  bool isCompletingTest = false;

  Map<String, dynamic>? testData;
  String? testAttemptId;
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  Map<String, String> userAnswers = {};

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _loadTest();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadTest() async {
    try {
      setState(() => isLoadingTest = true);

      // Load test by video ID
      final testResponse = await http.get(
        Uri.parse(
          'https://sicegah.vercel.app/api/tests/by-video/${widget.videoId}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (testResponse.statusCode == 200) {
        final testJson = json.decode(testResponse.body);
        if (testJson['success']) {
          testData = testJson['data'];

          // Create test attempt
          final attemptResponse = await http.post(
            Uri.parse('https://sicegah.vercel.app/api/test-attempts'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'userId': widget.userId,
              'testId': testData!['id'],
            }),
          );

          if (attemptResponse.statusCode == 200 ||
              attemptResponse.statusCode == 201) {
            final attemptJson = json.decode(attemptResponse.body);
            if (attemptJson['success']) {
              testAttemptId = attemptJson['data']['id'];
              _updateProgress();
            }
          }
        }
      }
    } catch (e) {
      print('Error loading test: $e');
      _showErrorDialog('Failed to load test. Please try again.');
    } finally {
      setState(() => isLoadingTest = false);
    }
  }

  void _updateProgress() {
    final progress =
        (currentQuestionIndex + 1) / (testData?['questions']?.length ?? 1);
    _progressController.animateTo(progress);
  }

  Future<void> _submitAnswer() async {
    if (selectedAnswer == null || testAttemptId == null) return;

    try {
      setState(() => isSubmittingAnswer = true);

      final question = testData!['questions'][currentQuestionIndex];

      final response = await http.post(
        Uri.parse('https://sicegah.vercel.app/api/user-answers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'questionId': question['id'],
          'testAttemptId': testAttemptId,
          'answer': selectedAnswer,
        }),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson['success']) {
          userAnswers[question['id']] = selectedAnswer!;

          // Show feedback briefly
          _showAnswerFeedback(
            responseJson['data']['isCorrect'],
            responseJson['data']['explanation'],
          );

          // Move to next question after showing feedback
          Future.delayed(const Duration(seconds: 2), () {
            if (currentQuestionIndex < (testData!['questions'].length - 1)) {
              setState(() {
                currentQuestionIndex++;
                selectedAnswer =
                    userAnswers[testData!['questions'][currentQuestionIndex]['id']];
                _updateProgress();
              });
            } else {
              _completeTest();
            }
          });
        }
      }
    } catch (e) {
      print('Error submitting answer: $e');
      _showErrorDialog('Failed to submit answer. Please try again.');
    } finally {
      setState(() => isSubmittingAnswer = false);
    }
  }

  void _showAnswerFeedback(bool isCorrect, String? explanation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isCorrect ? 'Benar!' : 'Salah!',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: explanation != null
            ? Text(explanation, style: const TextStyle(fontSize: 14))
            : null,
      ),
    );
  }

  Future<void> _completeTest() async {
    if (testAttemptId == null) return;

    try {
      setState(() => isCompletingTest = true);

      final response = await http.put(
        Uri.parse(
          'https://sicegah.vercel.app/api/test-attempts/$testAttemptId/complete',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId}),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson['success']) {
          _showResultDialog(responseJson['data']['summary']);
        }
      }
    } catch (e) {
      print('Error completing test: $e');
      _showErrorDialog('Failed to complete test. Please try again.');
    } finally {
      setState(() => isCompletingTest = false);
    }
  }

  void _showResultDialog(Map<String, dynamic> summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              summary['isPassed'] ? Icons.celebration : Icons.sentiment_neutral,
              color: summary['isPassed'] ? Colors.green : Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              summary['isPassed'] ? 'Selamat!' : 'Test Selesai',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor Anda: ${summary['score']}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Benar: ${summary['correctAnswers']}/${summary['totalQuestions']}',
            ),
            Text('Passing Score: ${summary['passingScore']}%'),
            if (summary['isPassed'])
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Anda telah lulus test ini!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close quiz page
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        final question = testData!['questions'][currentQuestionIndex];
        selectedAnswer = userAnswers[question['id']];
        _updateProgress();
      });
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < (testData!['questions'].length - 1)) {
      setState(() {
        currentQuestionIndex++;
        final question = testData!['questions'][currentQuestionIndex];
        selectedAnswer = userAnswers[question['id']];
        _updateProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingTest) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text('Test - ${widget.videoTitle}'),
          backgroundColor: Colors.deepOrange,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat test...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (testData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
          backgroundColor: Colors.deepOrange,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Test tidak ditemukan untuk video ini.'),
            ],
          ),
        ),
      );
    }

    final questions = testData!['questions'] as List;
    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['options'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Test - ${widget.videoTitle}'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soal ${currentQuestionIndex + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${((currentQuestionIndex + 1) / questions.length * 100).round()}%',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange,
                      ),
                      minHeight: 6,
                    );
                  },
                ),
              ],
            ),
          ),

          // Question Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.deepOrange[50]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            radius: 20,
                            child: Text(
                              "${currentQuestionIndex + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQuestion['questionText'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final alphabet = String.fromCharCode(65 + index);
                    final isSelected = selectedAnswer == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: isSelected ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.deepOrange
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: isSubmittingAnswer
                              ? null
                              : () {
                                  setState(() {
                                    selectedAnswer = option;
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.deepOrange
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      alphabet,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.deepOrange,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Submit Answer Button
                if (selectedAnswer != null &&
                    userAnswers[currentQuestion['id']] == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmittingAnswer ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmittingAnswer
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Mengirim...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'SUBMIT JAWABAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                // Navigation Buttons (only show if answer submitted)
                if (userAnswers[currentQuestion['id']] != null)
                  Row(
                    children: [
                      // Previous Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: currentQuestionIndex > 0
                              ? _goToPreviousQuestion
                              : null,
                          icon: Icon(
                            Icons.arrow_back,
                            color: currentQuestionIndex > 0
                                ? Colors.deepOrange
                                : Colors.grey,
                          ),
                          label: Text(
                            'SEBELUMNYA',
                            style: TextStyle(
                              color: currentQuestionIndex > 0
                                  ? Colors.deepOrange
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: currentQuestionIndex > 0
                                  ? Colors.deepOrange
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Next/Complete Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isCompletingTest
                              ? null
                              : () {
                                  if (currentQuestionIndex <
                                      questions.length - 1) {
                                    _goToNextQuestion();
                                  } else {
                                    _completeTest();
                                  }
                                },
                          icon: isCompletingTest
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  currentQuestionIndex < questions.length - 1
                                      ? Icons.arrow_forward
                                      : Icons.check_circle,
                                  color: Colors.white,
                                ),
                          label: Text(
                            isCompletingTest
                                ? 'MENYELESAIKAN...'
                                : currentQuestionIndex < questions.length - 1
                                ? 'SELANJUTNYA'
                                : 'SELESAI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                currentQuestionIndex < questions.length - 1
                                ? Colors.deepOrange
                                : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Info text
                if (selectedAnswer == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Pilih jawaban terlebih dahulu',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
