// quiz.dart - Improved version with better UI and no popup feedback
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz_result_page.dart'; // Import the result page

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
  List<Map<String, dynamic>> detailedResults = [];

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _loadTest();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadTest() async {
    try {
      setState(() => isLoadingTest = true);

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

          final attemptResponse = await http.post(
            Uri.parse('https://sicegah.vercel.app/api/test-attempts'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'userId': widget.userId.trim(),
              'testId': testData!['id'].toString(),
            }),
          );

          if (attemptResponse.statusCode == 200 ||
              attemptResponse.statusCode == 201) {
            final attemptJson = json.decode(attemptResponse.body);
            if (attemptJson['success']) {
              testAttemptId = attemptJson['data']['id'];
              _updateProgress();
              _slideController.forward();
            } else {
              throw Exception(
                'Failed to create test attempt: ${attemptJson['message']}',
              );
            }
          } else {
            throw Exception(
              'HTTP ${attemptResponse.statusCode}: ${attemptResponse.body}',
            );
          }
        } else {
          throw Exception('Test not found: ${testJson['message']}');
        }
      } else {
        throw Exception(
          'HTTP ${testResponse.statusCode}: ${testResponse.body}',
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to load test: $e');
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
      _scaleController.forward();

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = json.decode(response.body);
        if (responseJson['success']) {
          userAnswers[question['id']] = selectedAnswer!;

          detailedResults.add({
            'questionText': question['questionText'],
            'options': question['options'],
            'userAnswer': selectedAnswer,
            'correctAnswer': question['correctAnswer'],
            'isCorrect': responseJson['data']['isCorrect'],
            'explanation': responseJson['data']['explanation'] ?? '',
          });

          await Future.delayed(const Duration(milliseconds: 500));
          _scaleController.reverse();

          if (currentQuestionIndex < (testData!['questions'].length - 1)) {
            // Animate to next question
            await _slideController.reverse();
            setState(() {
              currentQuestionIndex++;
              selectedAnswer = null;
              _updateProgress();
            });
            _slideController.forward();
          } else {
            _completeTest();
          }
        } else {
          throw Exception('Submit failed: ${responseJson['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Failed to submit answer: $e');
    } finally {
      setState(() => isSubmittingAnswer = false);
    }
  }

  Future<void> _completeTest() async {
    if (testAttemptId == null) return;

    try {
      setState(() => isCompletingTest = true);

      // 1. Complete test
      final response = await http.put(
        Uri.parse(
          'https://sicegah.vercel.app/api/test-attempts/$testAttemptId/complete',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId.trim()}),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson['success']) {
          // 2. Get detailed results with correctAnswer - THE FIX!
          final resultsResponse = await http.get(
            Uri.parse(
              'https://sicegah.vercel.app/api/test-attempts/$testAttemptId/results',
            ),
            headers: {'Content-Type': 'application/json'},
          );

          if (resultsResponse.statusCode == 200) {
            final resultsJson = json.decode(resultsResponse.body);
            if (resultsJson['success']) {
              // 3. Navigate with COMPLETE data (including correctAnswer & explanation)
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => QuizResultPage(
                    summary: Map<String, dynamic>.from(
                      resultsJson['data']['summary'],
                    ),
                    detailedResults: List<Map<String, dynamic>>.from(
                      resultsJson['data']['detailedResults'],
                    ), // <- FIXED TYPE CASTING!
                    videoTitle: widget.videoTitle,
                  ),
                ),
              );
            } else {
              throw Exception('Get results failed: ${resultsJson['message']}');
            }
          } else {
            throw Exception(
              'HTTP ${resultsResponse.statusCode}: ${resultsResponse.body}',
            );
          }
        } else {
          throw Exception('Complete test failed: ${responseJson['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Failed to complete test: $e');
    } finally {
      setState(() => isCompletingTest = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error', style: TextStyle(color: Colors.red)),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingTest) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x000fffff), Color(0x000fffff), Color(0x000fffff)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [                
                // GAMBAR ILUSTRASI
                Image.asset(
                  "assets/images/welcome.gif",
                  width: 330,
                  height: 330,                
                ),                            
                SizedBox(height: 24),
                Text(
                  'Mempersiapkan Quiz...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (testData == null ||
        testData!['questions'] == null ||
        (testData!['questions'] as List).isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffA2D2FF), Color(0xFFFF865E), Color(0xFFFEE440)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz_outlined, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Quiz Tidak Tersedia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Maaf, quiz tidak ditemukan untuk video ini.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final questions = testData!['questions'] as List;
    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['options'] as List;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 54, 137, 255),
              Color.fromARGB(255, 72, 206, 251),
              Color(0xFFFEE440),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quiz Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.videoTitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentQuestionIndex + 1}/${questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress Section
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pertanyaan ${currentQuestionIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${((currentQuestionIndex + 1) / questions.length * 100).round()}% selesai',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.white, Colors.white70],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Question Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Drag Indicator
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Question Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 8, 219, 1),
                                        Color.fromARGB(255, 8, 224, 1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Soal ${currentQuestionIndex + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentQuestion['questionText'] ??
                                      'No question text',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Options
                          ...options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value.toString();
                            final alphabet = String.fromCharCode(65 + index);
                            final isSelected = selectedAnswer == option;

                            return AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: isSelected && isSubmittingAnswer
                                      ? _scaleAnimation.value
                                      : 1.0,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: isSubmittingAnswer
                                            ? null
                                            : () {
                                                setState(() {
                                                  selectedAnswer = option;
                                                });
                                              },
                                        borderRadius: BorderRadius.circular(16),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(
                                                    0xFFFF865E,
                                                  ).withOpacity(0.1)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFFF865E)
                                                  : Colors.grey.withOpacity(
                                                      0.2,
                                                    ),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFFF865E,
                                                      ).withOpacity(0.2),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.04),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: Row(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  gradient: isSelected
                                                      ? const LinearGradient(
                                                          colors: [
                                                            Color(0xFFFF865E),
                                                            Color.fromARGB(
                                                              255,
                                                              246,
                                                              145,
                                                              112,
                                                            ),
                                                          ],
                                                        )
                                                      : null,
                                                  color: isSelected
                                                      ? null
                                                      : const Color(0xFFF1F5F9),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    alphabet,
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF64748B,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
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
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF1E293B,
                                                          )
                                                        : const Color(
                                                            0xFF475569,
                                                          ),
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFFF865E,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Action
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (selectedAnswer != null &&
                                !isSubmittingAnswer &&
                                !isCompletingTest)
                            ? _submitAnswer
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF08CB00),
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: selectedAnswer != null ? 4 : 0,
                        ),
                        child: isSubmittingAnswer || isCompletingTest
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
                                    'Memproses...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentQuestionIndex == questions.length - 1
                                        ? 'Selesai Quiz'
                                        : 'Lanjut Soal',
                                    style: TextStyle(
                                      color: selectedAnswer != null
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    currentQuestionIndex == questions.length - 1
                                        ? Icons.check_circle
                                        : Icons.arrow_forward,
                                    color: selectedAnswer != null
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ],
                              ),
                      ),
                    ),

                    if (selectedAnswer == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Silakan pilih jawaban terlebih dahulu',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
