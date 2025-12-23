class GardenAssets {
  static String getTreeImage(String stage) {
    switch (stage) {
      case 'seed':
        return 'assets/garden/tree_0_seed.png';
      case 'sprout':
        return 'assets/garden/tree_1_sprout.png';
      case 'sapling':
        return 'assets/garden/tree_2_sapling.png';
      case 'young_tree':
        return 'assets/garden/tree_3_young.png';
      case 'majestic_tree':
        return 'assets/garden/tree_4_majestic.png';
      default:
        return 'assets/garden/tree_0_seed.png';
    }
  }
}
