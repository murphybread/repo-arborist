import 'package:repo_arborist/features/github/models/repository_stats_model.dart';

/// Encyclopedia entry for each plant family
class PlantEncyclopediaEntry {
  const PlantEncyclopediaEntry({
    required this.plantType,
    required this.familyName,
    required this.description,
    required this.languages,
    required this.characteristics,
    required this.growthInfo,
  });

  final PlantType plantType;
  final String familyName;
  final String description;
  final List<String> languages;
  final List<String> characteristics;
  final String growthInfo;
}

/// All encyclopedia entries for plant families
class PlantEncyclopedia {
  static const entries = [
    PlantEncyclopediaEntry(
      plantType: PlantType.blueberry,
      familyName: 'Blueberry Family',
      description:
          'The Blueberry family represents Dart and Flutter projects. '
          'Known for their vibrant indigo color and cross-platform capabilities, '
          'these plants thrive in modern mobile development environments.',
      languages: ['Dart', 'Flutter'],
      characteristics: [
        'Cross-platform mobile development',
        'Fast hot reload capabilities',
        'Beautiful, customizable UI',
      ],
      growthInfo:
          'Blueberry plants grow steadily with consistent commits and PRs. '
          'They bloom beautifully when well-maintained with regular updates.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.coffee,
      familyName: 'Coffee Family',
      description:
          'The Coffee family represents Java, Kotlin, and JVM-based projects. '
          'Strong and robust like a good cup of coffee, these plants are '
          'enterprise-grade and highly reliable.',
      languages: ['Java', 'Kotlin', 'Scala', 'JVM'],
      characteristics: [
        'Enterprise-level reliability',
        'Object-oriented architecture',
        'Wide ecosystem support',
      ],
      growthInfo:
          'Coffee plants are sturdy and long-lasting. They require '
          'consistent maintenance but can grow into massive trees.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.ginkgo,
      familyName: 'Ginkgo Family',
      description:
          'The Ginkgo family represents JavaScript and TypeScript projects. '
          'Like the ancient ginkgo tree, these plants are everywhere in the '
          'modern web ecosystem and extremely adaptable.',
      languages: ['JavaScript', 'TypeScript', 'Node.js'],
      characteristics: [
        'Universal web compatibility',
        'Event-driven architecture',
        'Massive package ecosystem',
      ],
      growthInfo:
          'Ginkgo plants grow rapidly with frequent updates. They adapt '
          'well to any environment and can reach impressive sizes.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.snakePlant,
      familyName: 'Snake Plant Family',
      description:
          'The Snake Plant family represents Python projects. Easy to grow '
          'and maintain, these plants are perfect for data science, AI, and '
          'automation tasks.',
      languages: ['Python', 'Jupyter Notebook'],
      characteristics: [
        'Easy to learn and maintain',
        'Excellent for data science',
        'Clean, readable syntax',
      ],
      growthInfo:
          'Snake plants are low-maintenance and grow steadily. They thrive '
          'in research and automation environments.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.fir,
      familyName: 'Fir Family',
      description:
          'The Fir family represents C, C++, Rust, and system-level projects. '
          'These are the strongest, most performant plants in the ecosystem, '
          'built for speed and efficiency.',
      languages: ['C', 'C++', 'Rust', 'Objective-C'],
      characteristics: [
        'Maximum performance',
        'Low-level system control',
        'Memory efficiency',
      ],
      growthInfo:
          'Fir trees grow slowly but become incredibly strong. They require '
          'careful attention to detail but offer unmatched performance.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.blossom,
      familyName: 'Blossom Family',
      description:
          'The Blossom family represents Swift and modern mobile projects. '
          'Beautiful and elegant, these plants create stunning user experiences '
          'on Apple platforms.',
      languages: ['Swift', 'SwiftUI', 'iOS'],
      characteristics: [
        'Beautiful native iOS apps',
        'Modern Swift syntax',
        'Apple ecosystem integration',
      ],
      growthInfo:
          'Blossom plants grow gracefully and bloom with elegant features. '
          'They shine brightest in the Apple ecosystem.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.bamboo,
      familyName: 'Bamboo Family',
      description:
          'The Bamboo family represents Go and Node.js projects. Fast-growing '
          'and lightweight, these plants excel at building scalable backend '
          'services and concurrent systems.',
      languages: ['Go', 'Golang', 'Node.js'],
      characteristics: [
        'Lightning-fast execution',
        'Excellent concurrency',
        'Simple, clean design',
      ],
      growthInfo:
          'Bamboo grows incredibly fast. With proper care, it can reach '
          'massive scale quickly and efficiently.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.oak,
      familyName: 'Oak Family',
      description:
          'The Oak family represents C#, PHP, and general-purpose projects. '
          'Sturdy and reliable, these are the traditional trees that have '
          'stood the test of time.',
      languages: ['C#', 'PHP', 'Perl', 'General'],
      characteristics: [
        'Reliable and stable',
        'Wide industry adoption',
        'Versatile applications',
      ],
      growthInfo:
          'Oak trees grow steadily and become reliable pillars. They are '
          'perfect for long-term enterprise projects.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.maple,
      familyName: 'Maple Family',
      description:
          'The Maple family represents Ruby, HTML, and web markup projects. '
          'Colorful and expressive, these plants add beauty and structure '
          'to the web.',
      languages: ['Ruby', 'HTML', 'CSS', 'SCSS'],
      characteristics: [
        'Elegant web design',
        'Developer-friendly syntax',
        'Strong web frameworks',
      ],
      growthInfo:
          'Maple trees grow with vibrant colors. They are essential for '
          'creating beautiful web experiences.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.cactus,
      familyName: 'Cactus Family',
      description:
          'The Cactus family represents Shell scripts, config files, and DevOps '
          'projects. Tough and resilient, these plants survive in harsh '
          'environments and keep systems running.',
      languages: ['Shell', 'Bash', 'Dockerfile', 'YAML'],
      characteristics: [
        'System automation',
        'Infrastructure as code',
        'Minimal dependencies',
      ],
      growthInfo:
          'Cacti are extremely resilient and require little maintenance. '
          'They are essential for DevOps ecosystems.',
    ),
    PlantEncyclopediaEntry(
      plantType: PlantType.pine,
      familyName: 'Pine Family',
      description:
          'The Pine family represents Assembly and embedded system projects. '
          'These are the most fundamental plants, working at the lowest level '
          'of computing.',
      languages: ['Assembly', 'VHDL', 'Verilog', 'Embedded'],
      characteristics: [
        'Hardware-level control',
        'Maximum optimization',
        'Bare-metal programming',
      ],
      growthInfo:
          'Pine trees grow from the ground up, literally. They represent '
          'the foundation of all computing systems.',
    ),
  ];

  /// Get entry by plant type
  static PlantEncyclopediaEntry? getEntry(PlantType plantType) {
    try {
      return entries.firstWhere((entry) => entry.plantType == plantType);
    } catch (e) {
      return null;
    }
  }
}

/// Growth stage information
class GrowthStageInfo {
  const GrowthStageInfo({
    required this.stage,
    required this.name,
    required this.description,
    required this.requirement,
  });

  final TreeStage stage;
  final String name;
  final String description;
  final String requirement;

  static const stages = [
    GrowthStageInfo(
      stage: TreeStage.sprout,
      name: 'Sprout',
      description:
          'A young project just starting its journey. Small but full of potential, '
          'sprouts represent new repositories with initial commits.',
      requirement: 'Score < 100 (commits × 1 + PRs × 3)',
    ),
    GrowthStageInfo(
      stage: TreeStage.bloom,
      name: 'Bloom',
      description:
          'A maturing project that has started to flourish. Blooming plants show '
          'active development with regular commits and merged pull requests.',
      requirement: 'Score 100-299 (commits × 1 + PRs × 3)',
    ),
    GrowthStageInfo(
      stage: TreeStage.tree,
      name: 'Tree',
      description:
          'A fully mature project with substantial development history. Trees '
          'represent well-established repositories with significant contributions.',
      requirement: 'Score ≥ 300 (commits × 1 + PRs × 3)',
    ),
  ];
}

/// Activity tier information
class ActivityTierInfo {
  const ActivityTierInfo({
    required this.tier,
    required this.name,
    required this.description,
    required this.timeframe,
    required this.visualEffect,
  });

  final ActivityTier tier;
  final String name;
  final String description;
  final String timeframe;
  final String visualEffect;

  static const tiers = [
    ActivityTierInfo(
      tier: ActivityTier.fresh,
      name: 'Fresh',
      description:
          'Recently active projects with ongoing development. These plants are '
          'vibrant and full of energy, showing strong commitment.',
      timeframe: 'Last activity within 7 days',
      visualEffect: 'Strong glow effect, +5% size, fresh appearance',
    ),
    ActivityTierInfo(
      tier: ActivityTier.warm,
      name: 'Warm',
      description:
          'Regularly maintained projects with recent updates. These plants are '
          'healthy and show consistent care.',
      timeframe: 'Last activity 8-30 days ago',
      visualEffect: 'Subtle sparkle effect, normal size',
    ),
    ActivityTierInfo(
      tier: ActivityTier.cooling,
      name: 'Cooling',
      description:
          'Projects with decreasing activity. These plants are still alive but '
          'haven\'t been watered in a while.',
      timeframe: 'Last activity 31-180 days ago',
      visualEffect: '70% saturation, no glow, slightly faded',
    ),
    ActivityTierInfo(
      tier: ActivityTier.dormant,
      name: 'Dormant',
      description:
          'Inactive projects in hibernation. These plants are resting and need '
          'attention to flourish again.',
      timeframe: 'Last activity over 180 days ago',
      visualEffect: '50% saturation, -5% size, sepia tone',
    ),
  ];
}
