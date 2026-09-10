const reportCategories = <String>[
  'Pothole',
  'Road Damage',
  'Traffic Signals',
  'Road Markings',
  'Flooding',
  'Drainage Issue',
  'Road Obstruction',
  'Fallen Tree',
  'Street Lighting',
  'Road Signage',
  'Guardrail / Barrier',
  'Bridge / Tunnel Damage',
  'Pedestrian Facilities',
  'Road Spill',
];

typedef ReportImageLabel = ({String text, double confidence});
typedef ReportCategorySuggestion = ({String category, double confidence});

class ReportCategoryAnalysis {
  final List<ReportCategorySuggestion> suggestions;
  final bool canAutoSelect;

  const ReportCategoryAnalysis({
    required this.suggestions,
    required this.canAutoSelect,
  });
}

const _categoryLabelWeights = <String, Map<String, double>>{
  'Pothole': {
    'pothole': 4.0,
    'sinkhole': 3.8,
    'crater': 3.2,
    'road hole': 3.0,
    'hole': 2.6,
  },
  'Road Damage': {
    'road crack': 3.6,
    'cracked road': 3.6,
    'damaged road': 3.5,
    'broken pavement': 3.0,
    'asphalt': 1.8,
    'crack': 2.8,
    'collapsed pavement': 3.4,
    'surface damage': 3.0,
  },
  'Traffic Signals': {
    'fallen traffic light': 4.5,
    'broken traffic light': 4.5,
    'traffic light pole': 4.4,
    'signal pole': 4.2,
    'traffic light': 4.0,
    'traffic signal': 4.0,
    'traffic control device': 3.8,
    'stoplight': 4.0,
    'signal light': 3.5,
    'signal': 1.5,
  },
  'Road Markings': {
    'road marking': 4.0,
    'lane marking': 3.8,
    'zebra crossing': 3.8,
    'crosswalk': 3.5,
    'painted line': 3.0,
    'lane': 1.3,
  },
  'Flooding': {
    'flash flood': 4.5,
    'floodwater': 4.2,
    'flood': 4.0,
    'submerged': 3.8,
    'inundation': 3.8,
    'standing water': 3.5,
    'puddle': 3.2,
    'water': 2.8,
    'rain': 1.2,
  },
  'Drainage Issue': {
    'storm drain': 4.0,
    'blocked drain': 4.0,
    'drainage': 3.8,
    'drain': 3.2,
    'culvert': 3.2,
    'sewer': 3.0,
    'manhole': 2.8,
    'gutter': 2.4,
    'ditch': 2.0,
    'grate': 1.5,
  },
  'Road Obstruction': {
    'blocked road': 4.0,
    'road block': 3.8,
    'obstruction': 3.8,
    'barricade': 3.2,
    'debris': 2.8,
    'traffic cone': 2.4,
    'wreckage': 2.4,
    'rubble': 1.8,
  },
  'Fallen Tree': {
    'fallen tree': 4.5,
    'downed tree': 4.5,
    'uprooted tree': 4.2,
    'tree trunk': 3.0,
    'fallen branch': 3.5,
    'branch': 1.4,
    'tree': .5,
  },
  'Street Lighting': {
    'street light': 4.2,
    'streetlight': 4.2,
    'lamp post': 3.8,
    'lamppost': 3.8,
    'lighting pole': 3.4,
    'street lamp': 3.4,
    'lamp': 1.2,
  },
  'Road Signage': {
    'road sign': 4.0,
    'traffic sign': 4.0,
    'signpost': 3.5,
    'signage': 3.2,
    'warning sign': 3.2,
    'sign': .8,
  },
  'Guardrail / Barrier': {
    'guardrail': 4.2,
    'guard rail': 4.2,
    'crash barrier': 3.8,
    'road barrier': 3.2,
    'railing': 2.0,
    'barrier': 1.4,
    'fence': .7,
  },
  'Bridge / Tunnel Damage': {
    'damaged bridge': 4.5,
    'bridge crack': 4.2,
    'damaged tunnel': 4.5,
    'tunnel crack': 4.2,
    'retaining wall': 2.5,
    'overpass': 1.6,
    'underpass': 1.6,
    'bridge': .8,
    'tunnel': .8,
  },
  'Pedestrian Facilities': {
    'broken sidewalk': 4.0,
    'damaged walkway': 4.0,
    'pedestrian crossing': 3.8,
    'wheelchair ramp': 3.5,
    'footpath': 3.0,
    'sidewalk': 2.8,
    'walkway': 2.6,
    'crosswalk': 2.4,
    'pedestrian': 1.5,
  },
  'Road Spill': {
    'oil spill': 4.2,
    'fuel spill': 4.2,
    'chemical spill': 4.2,
    'spilled liquid': 3.5,
    'spill': 3.2,
    'oil': 2.0,
    'fuel': 2.0,
    'mud': 1.8,
    'gravel': 1.6,
    'sand': 1.2,
  },
};

ReportCategoryAnalysis analyseReportCategories(
  Iterable<ReportImageLabel> labels,
) {
  final scores = <String, double>{};
  final strongestWeights = <String, double>{};
  final strongestConfidences = <String, double>{};

  for (final label in labels) {
    final text = label.text.trim().toLowerCase().replaceAll(
      RegExp(r'[_-]+'),
      ' ',
    );
    if (text.isEmpty) continue;
    for (final category in reportCategories) {
      final keywords = _categoryLabelWeights[category] ?? const {};
      var strongestWeight = 0.0;
      for (final keyword in keywords.entries) {
        if (text.contains(keyword.key) && keyword.value > strongestWeight) {
          strongestWeight = keyword.value;
        }
      }
      if (strongestWeight == 0) continue;
      scores[category] =
          (scores[category] ?? 0) + label.confidence * strongestWeight;
      final previousWeight = strongestWeights[category] ?? 0;
      final previousConfidence = strongestConfidences[category] ?? 0;
      if (strongestWeight > previousWeight ||
          (strongestWeight == previousWeight &&
              label.confidence > previousConfidence)) {
        strongestWeights[category] = strongestWeight;
        strongestConfidences[category] = label.confidence;
      }
    }
  }

  final ranked = <({String category, double score, double confidence})>[];
  for (final category in reportCategories) {
    final score = scores[category] ?? 0;
    final strongestWeight = strongestWeights[category] ?? 0;
    final strongestConfidence = strongestConfidences[category] ?? 0;
    if (score < .8 || strongestWeight < 2.4 || strongestConfidence < .45) {
      continue;
    }
    final evidence = (score / 4).clamp(0.0, 1.0);
    final specificity = (strongestWeight / 4.5).clamp(0.0, 1.0);
    final confidence =
        (strongestConfidence * .7 + evidence * .2 + specificity * .1).clamp(
          0.0,
          .99,
        );
    ranked.add((category: category, score: score, confidence: confidence));
  }
  ranked.sort((first, second) => second.score.compareTo(first.score));

  if (ranked.isEmpty) {
    return const ReportCategoryAnalysis(suggestions: [], canAutoSelect: false);
  }

  final top = ranked.first;
  final hasClearLead =
      ranked.length == 1 || top.score >= ranked[1].score * 1.25;
  final suggestions = ranked
      .take(3)
      .map((item) => (category: item.category, confidence: item.confidence))
      .toList(growable: false);
  return ReportCategoryAnalysis(
    suggestions: suggestions,
    canAutoSelect: top.confidence >= .68 && hasClearLead,
  );
}

List<String> reportCategoryOptions(String currentCategory) {
  if (currentCategory.isEmpty || reportCategories.contains(currentCategory)) {
    return reportCategories;
  }
  return [currentCategory, ...reportCategories];
}
