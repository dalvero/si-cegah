// widgets/celebration_snackbar.dart - Snackbar apresiasi dengan animasi
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';

class CelebrationSnackbar {
  // Show celebration snackbar with trumpet animation
  static void show(
    BuildContext context, {
    required String message,
    required int starRating,
    List<String> achievementsUnlocked = const [],
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CelebrationOverlay(
        message: message,
        starRating: starRating,
        achievementsUnlocked: achievementsUnlocked,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class CelebrationOverlay extends StatefulWidget {
  final String message;
  final int starRating;
  final List<String> achievementsUnlocked;
  final VoidCallback onDismiss;

  const CelebrationOverlay({
    Key? key,
    required this.message,
    required this.starRating,
    required this.achievementsUnlocked,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _trumpetController;
  late AnimationController _starController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _trumpetAnimation;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    // Trumpet bounce animation
    _trumpetController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _trumpetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trumpetController, curve: Curves.bounceOut),
    );

    // Star rating animation
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.elasticOut),
    );

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _trumpetController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _starController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _trumpetController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Animated Trumpet Icon
                    AnimatedBuilder(
                      animation: _trumpetAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _trumpetAnimation.value,
                          child: Transform.rotate(
                            angle: _trumpetAnimation.value * 0.2,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🎺',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 12),

                    // Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dismiss button
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                // Animated Star Rating
                if (widget.starRating > 0) ...[
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final delay = index * 0.1;
                          final animationValue = (_starAnimation.value - delay)
                              .clamp(0.0, 1.0);

                          return Transform.scale(
                            scale: animationValue,
                            child: Icon(
                              index < widget.starRating
                                  ? Icons.star
                                  : Icons.star_outline,
                              color: index < widget.starRating
                                  ? Colors.amber
                                  : Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],

                // Achievement badges
                if (widget.achievementsUnlocked.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          widget.achievementsUnlocked.length == 1
                              ? 'Badge Baru: ${widget.achievementsUnlocked.first}'
                              : '+${widget.achievementsUnlocked.length} Badge Baru',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
