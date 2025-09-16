// quiz_result_page.dart - Improved version with better data handling
import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> detailedResults;
  final String videoTitle;

  const QuizResultPage({
    super.key,
    required this.summary,
    required this.detailedResults,
    required this.videoTitle,
  });

  // Helper method to safely get summary data
  Map<String, dynamic> get safeSummary => {
    'score': summary['score'] ?? 0,
    'isPassed': summary['isPassed'] ?? false,
    'totalQuestions': summary['totalQuestions'] ?? detailedResults.length,
    'correctAnswers': summary['correctAnswers'] ?? 0,
    'passingScore': summary['passingScore'] ?? 70,
    'totalPointsEarned': summary['totalPointsEarned'] ?? 0,
    'totalMaxPoints': summary['totalMaxPoints'] ?? 0,
    'timeSpent': summary['timeSpent'] ?? 0,
  };

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  Color _getScoreColor() {
    final score = safeSummary['score'] as int;
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = safeSummary;
    final isPassed = summaryData['isPassed'] as bool;
    final score = summaryData['score'] as int;
    final totalQuestions = summaryData['totalQuestions'] as int;
    final correctAnswers = summaryData['correctAnswers'] as int;
    final passingScore = summaryData['passingScore'] as int;
    final timeSpent = summaryData['timeSpent'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Score Header with enhanced design
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPassed
                    ? [
                        Color.fromARGB(255, 54, 137, 255)!,
                        Color.fromARGB(255, 72, 206, 251)!,
                      ]
                    : [Colors.orange[400]!, Colors.orange[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Achievement Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPassed
                            ? Icons.celebration
                            : score >= passingScore * 0.8
                            ? Icons.sentiment_satisfied
                            : Icons.sentiment_neutral,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Result Message
                    Text(
                      isPassed ? 'Selamat! Anda Lulus' : 'Test Selesai',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Score Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '%',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Statistics Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          'Benar',
                          '$correctAnswers/$totalQuestions',
                          Icons.check_circle,
                        ),
                        _buildStatItem(
                          'Passing Score',
                          '$passingScore%',
                          Icons.flag,
                        ),
                        if (timeSpent > 0)
                          _buildStatItem(
                            'Waktu',
                            _formatTime(timeSpent),
                            Icons.timer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Review Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.quiz, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Review Jawaban',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (detailedResults.isNotEmpty)
                  Text(
                    '${detailedResults.length} Soal',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
              ],
            ),
          ),

          // Questions Review
          Expanded(
            child: detailedResults.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Detail jawaban tidak tersedia',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: detailedResults.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(index);
                    },
                  ),
          ),

          // Bottom Actions
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
                // Performance Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.green[50] : Colors.orange[50]!,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPassed
                          ? Colors.green[200]!
                          : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPassed ? Icons.thumb_up : Icons.info_outline,
                        color: isPassed
                            ? Colors.green[600]
                            : Colors.orange[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isPassed
                              ? 'Hebat! Anda telah menguasai materi dengan baik.'
                              : score >= passingScore * 0.8
                              ? 'Hampir berhasil! Pelajari kembali materi dan coba lagi.'
                              : 'Perlu lebih banyak belajar. Tonton ulang video dan coba lagi.',
                          style: TextStyle(
                            color: isPassed
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Retake Test Button (if failed)
                    if (!isPassed)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Back to quiz
                            Navigator.of(context).pop(); // Back to video page
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.deepOrange,
                          ),
                          label: const Text(
                            'ULANGI TEST',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: Colors.deepOrange,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                    if (!isPassed) const SizedBox(width: 12),

                    // Continue Button
                    Expanded(
                      flex: isPassed ? 1 : 1,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate back to home/course page
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        icon: Icon(
                          isPassed ? Icons.play_arrow : Icons.home,
                          color: Colors.white,
                        ),
                        label: Text(
                          isPassed
                              ? 'LANJUT VIDEO BERIKUTNYA'
                              : 'KEMBALI KE BERANDA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPassed
                              ? Colors.green
                              : Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final result = detailedResults[index];
    final isCorrect = result['isCorrect'] ?? false;
    final questionText = result['questionText'] ?? 'Pertanyaan tidak tersedia';
    final options = (result['options'] ?? []) as List;
    final userAnswer = result['userAnswer'] ?? '';
    final correctAnswer = result['correctAnswer'] ?? '';
    final explanation = result['explanation'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'Benar' : 'Salah',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Soal ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question Text
            Text(
              questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Options with highlighting
            ...options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value.toString();
              final alphabet = String.fromCharCode(65 + optionIndex);

              final isUserAnswer = userAnswer == option;
              final isCorrectAnswer = correctAnswer == option;

              Color backgroundColor = Colors.grey[50]!;
              Color borderColor = Colors.grey[300]!;
              Color textColor = Colors.black;
              Widget? trailingIcon;

              if (isCorrectAnswer && isUserAnswer) {
                // User correct answer
                backgroundColor = Colors.green[50]!;
                borderColor = Colors.green;
                textColor = Colors.green[800]!;
                trailingIcon = const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                );
              } else if (isCorrectAnswer && !isUserAnswer) {
                // Correct answer but user didn't select
                backgroundColor = Colors.green[50]!;
                borderColor = Colors.green;
                textColor = Colors.green[800]!;
                trailingIcon = const Icon(Icons.lightbulb, color: Colors.green);
              } else if (isUserAnswer && !isCorrectAnswer) {
                // User wrong answer
                backgroundColor = Colors.red[50]!;
                borderColor = Colors.red;
                textColor = Colors.red[800]!;
                trailingIcon = const Icon(Icons.cancel, color: Colors.red);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrectAnswer || isUserAnswer
                              ? (isCorrectAnswer ? Colors.green : Colors.red)
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            alphabet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: (isCorrectAnswer || isUserAnswer)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) trailingIcon,
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Explanation
            if (explanation.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Penjelasan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      explanation,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
