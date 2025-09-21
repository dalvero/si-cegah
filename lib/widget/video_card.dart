// widget/video_card.dart - Clean production version
import 'package:flutter/material.dart';
import '../services/user_service.dart';

class VideoCard extends StatefulWidget {
  final String title;
  final String category;
  final String duration;
  final String thumbnail;
  final String description;
  final String videoId;
  final String? userId;
  final double rating;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.title,
    required this.category,
    required this.duration,
    required this.thumbnail,
    required this.description,
    required this.videoId,
    this.userId,
    required this.rating,
    required this.onTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  int userStarRating = 0;
  bool isLoadingStars = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserStarRating();
    }
  }

  Future<void> _loadUserStarRating() async {
    if (widget.userId == null) return;

    setState(() {
      isLoadingStars = true;
    });

    try {
      final starRating = await UserService.getUserStarRating(
        widget.userId!,
        widget.videoId,
      );

      if (mounted) {
        setState(() {
          userStarRating = starRating;
          isLoadingStars = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingStars = false;
          userStarRating = 0;
        });
      }
    }
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.videoId != widget.videoId) {
      if (widget.userId != null) {
        _loadUserStarRating();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 385,
        margin: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DYNAMIC STAR RATING
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isLoadingStars)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.amber,
                      ),
                    )
                  else
                    Row(
                      children: List.generate(5, (index) {
                        final bool isYellow =
                            userStarRating > 0 && index < userStarRating;

                        return Icon(
                          isYellow ? Icons.star : Icons.star_outline,
                          color: isYellow ? Colors.amber : Colors.grey[300],
                          size: 16,
                        );
                      }),
                    ),
                ],
              ),
            ),

            // Thumbnail container
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.thumbnail,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.grey,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),

                  // COMPLETION BADGE
                  if (userStarRating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Selesai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Play button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    widget.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                  ),

                  // PROGRESS INDICATOR
                  if (userStarRating > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$userStarRating/5 Bintang',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
