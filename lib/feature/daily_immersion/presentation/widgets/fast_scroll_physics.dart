import 'package:flutter/material.dart';

class FastScrollPhysics extends ScrollPhysics {
  const FastScrollPhysics({super.parent});

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // 1. Setup dimensions
    final double pageSize = position.viewportDimension;
    final double currentPixels = position.pixels;

    // 2. Determine which page is "closest" right now (Round)
    final int closestPage = (currentPixels / pageSize).round();
    final double closestPagePixels = closestPage * pageSize;

    // 3. Calculate how far we are from that closest page
    // Positive = we pulled slightly down (towards next)
    // Negative = we pulled slightly up (towards previous)
    final double delta = currentPixels - closestPagePixels;

    double targetPixels;

    // 4. THE LOGIC: Ultra-Sensitive Snapping
    // If velocity is high, let standard flinging handle it.
    // If velocity is low (drag and drop), we check for "slight snips".

    if (velocity.abs() > 800) {
      // Standard fling behavior if user flicks fast
      targetPixels = velocity > 0
          ? (closestPage + (delta > 0 ? 1 : 0)) * pageSize
          : (closestPage - (delta < 0 ? 1 : 0)) * pageSize;
    } else {
      // User dragged slowly or just a tiny bit.
      // We set a tiny threshold (e.g., 10 pixels).
      // If you moved just 10 pixels away from the center, we commit to the move.

      final double sensitivityThreshold = pageSize * 0.05;

      if (delta > sensitivityThreshold) {
        // User moved slightly down -> Go Next
        targetPixels = (closestPage + 1) * pageSize;
      } else if (delta < -sensitivityThreshold) {
        // User moved slightly up -> Go Previous
        targetPixels = (closestPage - 1) * pageSize;
      } else {
        // User barely touched it -> Snap back
        targetPixels = closestPagePixels;
      }
    }

    // 5. Bounds Check (Don't scroll past start or end)
    targetPixels = targetPixels.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    // 6. Create the Spring (Snap effect)
    return ScrollSpringSimulation(
      const SpringDescription(mass: 0.5, stiffness: 800, damping: 30),
      position.pixels,
      targetPixels,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}
