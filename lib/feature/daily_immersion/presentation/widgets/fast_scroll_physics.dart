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
    final double pixels = position.pixels;
    final double viewport = position.viewportDimension;

    // Safety check
    if (viewport <= 0) return null;

    // 1. Calculate where we are exactly (e.g., 2.15 means 15% into page 2)
    final double exactPage = pixels / viewport;
    final int currentPage = exactPage.floor();
    final double pageOffset = exactPage - currentPage;

    // 2. Sensitivity Config
    // 0.12 means you only need to drag 12% of the screen height to snap next
    const double dragThreshold = 0.12;
    const double velocityThreshold = 300.0;

    double targetPixels;

    // 3. Logic Tree
    if (velocity > velocityThreshold) {
      // Fast Flick DOWN -> Go Next
      targetPixels = (currentPage + 1) * viewport;
    } else if (velocity < -velocityThreshold) {
      // Fast Flick UP -> Go Previous (or snap to current if at top of page)
      // Logic: If we are at 2.9 and flick up, we want 2.0.
      // If we are at 2.1 and flick up, we want 1.0 (handled by round/floor logic usually, but let's be explicit)
      targetPixels = currentPage * viewport;

      // If we were already partially down the page (e.g. 2.1) and flicked up,
      // exactPage might be 2.1. We want to go to 2.0.
      // If we were at 2.9 (dragging up from 3) and flicked up, we want 2.0.
    } else {
      // SLOW DRAG / RELEASE

      if (pageOffset > dragThreshold) {
        // Dragged > 12% down -> Snap to Next
        targetPixels = (currentPage + 1) * viewport;
      } else if (pageOffset < (1 - dragThreshold) && pageOffset > 0.0) {
        // Dragged > 12% up (technically showing bottom of prev page) -> Snap to Previous
        // Note: In a PageView, dragging UP usually decreases pixels.
        // If we are at 2.0 and drag up, pixels go 1.9.
        // This block handles the "reset" if you didn't drag enough.
        targetPixels = currentPage * viewport;
      } else {
        // Didn't drag enough? Snap back to start of current page
        targetPixels = currentPage * viewport;
      }
    }

    // 4. Strict clamping (Fixes the "pass many pages" bug)
    targetPixels = targetPixels.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    // 5. If we are already at the target, let things settle
    if ((targetPixels - pixels).abs() < 0.01) return null;

    // 6. The Animation Spring
    return ScrollSpringSimulation(
      const SpringDescription(
        mass: 60, // Lighter mass = starts moving faster
        stiffness: 150, // Higher stiffness = stronger magnetic snap
        damping: 1.1, // Slightly overdamped to prevent bounce-back
      ),
      pixels,
      targetPixels,
      velocity,
      tolerance: toleranceFor(position),
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
