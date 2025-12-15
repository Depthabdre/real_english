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
    // Default behavior at edges
    if ((position.pixels <= position.minScrollExtent && velocity < 0.0) ||
        (position.pixels >= position.maxScrollExtent && velocity > 0.0)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double pageHeight = position.viewportDimension;
    final int currentPage = (position.pixels / pageHeight).floor();
    final double currentPagePixels = currentPage * pageHeight;

    double target = currentPagePixels;

    const double flickVelocity = 5.0; // very light flick

    // 1️⃣ Any flick → move immediately
    if (velocity.abs() > flickVelocity) {
      target += velocity > 0 ? pageHeight : -pageHeight;
    }
    // 2️⃣ ANY drag (even 1px) → move
    else {
      final double drag = position.pixels - currentPagePixels;

      if (drag > 0) {
        target += pageHeight; // drag down
      } else if (drag < 0) {
        target -= pageHeight; // drag up
      }
    }

    final double clampedTarget = target.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    return ScrollSpringSimulation(
      SpringDescription(mass: 0.45, stiffness: 650.0, damping: 48.0),
      position.pixels,
      clampedTarget,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}
