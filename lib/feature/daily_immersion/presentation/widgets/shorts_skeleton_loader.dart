import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShortsSkeletonLoader extends StatelessWidget {
  const ShortsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark theme base colors for the shimmer
    final baseColor = Colors.grey[900]!;
    final highlightColor = Colors.grey[800]!;

    return Container(
      color: Colors.black, // Background of the video player
      width: double.infinity,
      height: double.infinity,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Stack(
          children: [
            // 1. Right Side Action Buttons (Like, Comment, Share)
            Positioned(
              right: 16,
              bottom: 100, // Adjust based on your real UI
              child: Column(
                children: [
                  _buildCircle(50), // Profile Pic
                  const SizedBox(height: 25),
                  _buildCircle(40), // Like
                  const SizedBox(height: 25),
                  _buildCircle(40), // Comment
                  const SizedBox(height: 25),
                  _buildCircle(40), // Share
                ],
              ),
            ),

            // 2. Bottom Text Area (Title & Description)
            Positioned(
              left: 16,
              bottom: 40,
              right: 80, // Leave space for buttons
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRectangle(width: 150, height: 20), // Username/Channel
                  const SizedBox(height: 10),
                  _buildRectangle(
                    width: double.infinity,
                    height: 16,
                  ), // Description Line 1
                  const SizedBox(height: 6),
                  _buildRectangle(width: 200, height: 16), // Description Line 2
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

  Widget _buildRectangle({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
