import 'package:flutter/material.dart';

enum CropStageStatus { completed, ongoing, upcoming }

class CropStagePest {
  const CropStagePest({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class CropStage {
  const CropStage({
    required this.title,
    required this.subtitle,
    required this.startDay,
    required this.endDay,
    this.watchFor = const [],
  });

  final String title;
  final String subtitle;
  final int startDay;
  final int endDay;
  final List<CropStagePest> watchFor;

  CropStageStatus statusAt(int daysSinceSowing) {
    if (daysSinceSowing > endDay) return CropStageStatus.completed;
    if (daysSinceSowing >= startDay) return CropStageStatus.ongoing;
    return CropStageStatus.upcoming;
  }
}

/// Generic crop-cycle timelines built from commonly published state
/// agriculture extension guidance — day ranges are typical, not a
/// field-specific schedule.
const Map<String, List<CropStage>> cultivationTimelines = {
  'Wheat': [
    CropStage(title: '2 weeks before sowing', subtitle: 'Plant selection & field prep', startDay: -14, endDay: -1),
    CropStage(
      title: 'Week 1–2',
      subtitle: 'Seedling stage',
      startDay: 0,
      endDay: 14,
      watchFor: [
        CropStagePest(name: 'Termites', icon: Icons.bug_report_outlined),
        CropStagePest(name: 'Aphids', icon: Icons.pest_control_outlined),
      ],
    ),
    CropStage(title: 'Week 3–6', subtitle: 'Vegetative (tillering) stage', startDay: 15, endDay: 42),
    CropStage(title: 'Week 7–9', subtitle: 'Flowering (heading) stage', startDay: 43, endDay: 63),
    CropStage(title: 'Week 10–14', subtitle: 'Grain filling stage', startDay: 64, endDay: 98),
    CropStage(title: 'Week 15+', subtitle: 'Maturity & harvest', startDay: 99, endDay: 120),
  ],
  'Cotton': [
    CropStage(title: '2 weeks before sowing', subtitle: 'Plant selection & field prep', startDay: -14, endDay: -1),
    CropStage(
      title: 'Week 1–2',
      subtitle: 'Seedling stage',
      startDay: 0,
      endDay: 14,
      watchFor: [
        CropStagePest(name: 'Leafhoppers & Jassids', icon: Icons.bug_report_outlined),
        CropStagePest(name: 'Leaf Miner Flies', icon: Icons.pest_control_outlined),
        CropStagePest(name: 'Aphids', icon: Icons.coronavirus_outlined),
      ],
    ),
    CropStage(title: 'Week 3–8', subtitle: 'Vegetative & squaring stage', startDay: 15, endDay: 56),
    CropStage(title: 'Week 9–14', subtitle: 'Flowering & boll formation', startDay: 57, endDay: 98),
    CropStage(title: 'Week 15–20', subtitle: 'Boll maturity stage', startDay: 99, endDay: 140),
    CropStage(title: 'Week 21+', subtitle: 'Picking & harvest', startDay: 141, endDay: 180),
  ],
  'Rice': [
    CropStage(title: '2 weeks before transplanting', subtitle: 'Nursery raising', startDay: -14, endDay: -1),
    CropStage(
      title: 'Week 1–3',
      subtitle: 'Seedling stage',
      startDay: 0,
      endDay: 21,
      watchFor: [
        CropStagePest(name: 'Stem Borer', icon: Icons.bug_report_outlined),
        CropStagePest(name: 'Leaf Folder', icon: Icons.pest_control_outlined),
      ],
    ),
    CropStage(title: 'Week 4–8', subtitle: 'Tillering stage', startDay: 22, endDay: 56),
    CropStage(title: 'Week 9–11', subtitle: 'Panicle initiation & flowering', startDay: 57, endDay: 77),
    CropStage(title: 'Week 12–15', subtitle: 'Grain filling stage', startDay: 78, endDay: 105),
    CropStage(title: 'Week 16+', subtitle: 'Maturity & harvest', startDay: 106, endDay: 130),
  ],
  'Tomato': [
    CropStage(title: '2 weeks before transplanting', subtitle: 'Nursery raising', startDay: -14, endDay: -1),
    CropStage(
      title: 'Week 1–2',
      subtitle: 'Seedling stage',
      startDay: 0,
      endDay: 14,
      watchFor: [
        CropStagePest(name: 'Cutworms', icon: Icons.bug_report_outlined),
        CropStagePest(name: 'Aphids', icon: Icons.coronavirus_outlined),
      ],
    ),
    CropStage(title: 'Week 3–5', subtitle: 'Vegetative stage', startDay: 15, endDay: 35),
    CropStage(title: 'Week 6–8', subtitle: 'Flowering stage', startDay: 36, endDay: 56),
    CropStage(title: 'Week 9–13', subtitle: 'Fruiting & ripening stage', startDay: 57, endDay: 91),
    CropStage(title: 'Week 14+', subtitle: 'Harvest window', startDay: 92, endDay: 110),
  ],
  'Maize': [
    CropStage(title: '2 weeks before sowing', subtitle: 'Plant selection & field prep', startDay: -14, endDay: -1),
    CropStage(
      title: 'Week 1–2',
      subtitle: 'Seedling stage',
      startDay: 0,
      endDay: 14,
      watchFor: [
        CropStagePest(name: 'Fall Armyworm', icon: Icons.bug_report_outlined),
        CropStagePest(name: 'Termites', icon: Icons.pest_control_outlined),
      ],
    ),
    CropStage(title: 'Week 3–6', subtitle: 'Vegetative stage', startDay: 15, endDay: 42),
    CropStage(title: 'Week 7–9', subtitle: 'Tasseling & silking stage', startDay: 43, endDay: 63),
    CropStage(title: 'Week 10–13', subtitle: 'Grain filling stage', startDay: 64, endDay: 91),
    CropStage(title: 'Week 14+', subtitle: 'Maturity & harvest', startDay: 92, endDay: 110),
  ],
};
