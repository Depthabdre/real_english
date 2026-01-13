import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // Adapt colors based on theme for a natural look
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Skeleton Title
        title: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: _buildRectangle(width: 150, height: 28, radius: 8),
        ),
        actions: [
          // Skeleton Theme Toggle
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: _buildCircle(40),
            ),
          ),
        ],
      ),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 1. IDENTITY HEADER
              // Matches ProfileHeader layout
              Row(
                children: [
                  _buildCircle(72), // Avatar (Radius 36 * 2)
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRectangle(
                        width: 180,
                        height: 24,
                        radius: 6,
                      ), // Name
                      const SizedBox(height: 10),
                      _buildRectangle(
                        width: 120,
                        height: 20,
                        radius: 20,
                      ), // Badge
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. GARDEN CARD SECTION
              _buildRectangle(
                width: 120,
                height: 20,
                radius: 4,
              ), // "Your Growth" Title
              const SizedBox(height: 16),
              // The Big Garden Card
              _buildRectangle(
                width: double.infinity,
                height: 360, // Matches GardenShowcaseCard height
                radius: 32, // Matches corner radius
              ),

              const SizedBox(height: 32),

              // 3. STATS SECTION
              _buildRectangle(
                width: 160,
                height: 20,
                radius: 4,
              ), // "Nutrients" Title
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRectangle(
                      width: double.infinity,
                      height: 160, // Matches ProfileStatsRow height
                      radius: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRectangle(
                      width: double.infinity,
                      height: 160,
                      radius: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // 4. LOGOUT BUTTON
              Center(
                child: _buildRectangle(
                  width: 200,
                  height: 50,
                  radius: 30, // Matches pill button
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

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
