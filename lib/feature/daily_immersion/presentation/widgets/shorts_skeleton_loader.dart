import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShortsSkeletonLoader extends StatelessWidget {
  const ShortsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[900]!;
    final highlightColor = Colors.grey[800]!;

    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Stack(
          children: [
            // Action Buttons (Right)
            Positioned(
              right: 16,
              bottom: 120, // Match the padding of real content
              child: Column(
                children: [
                  _buildCircle(50), // Save
                  const SizedBox(height: 25),
                  _buildCircle(50), // Got it
                ],
              ),
            ),

            // Text Area (Left)
            Positioned(
              left: 16,
              bottom: 120,
              right: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRectangle(width: 60, height: 20, radius: 20), // Badge
                  const SizedBox(height: 12),
                  _buildRectangle(width: 200, height: 24, radius: 4), // Title
                  const SizedBox(height: 8),
                  _buildRectangle(
                    width: 150,
                    height: 24,
                    radius: 4,
                  ), // Title Line 2
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildRectangle(width: 60, height: 16, radius: 8), // Tag
                      const SizedBox(width: 8),
                      _buildRectangle(width: 60, height: 16, radius: 8), // Tag
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRectangle({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
