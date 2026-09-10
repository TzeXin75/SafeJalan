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
    'rubble': 1.0,
    'construction': .6,
    'road': .2,
  },
  'Traffic Signals': {
    'traffic light': 4.0,
    'traffic signal': 4.0,
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

(String, double)? suggestReportCategory(Iterable<ReportImageLabel> labels) {
  final scores = <String, double>{};
  final strongestConfidence = <String, double>{};

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
      if (label.confidence > (strongestConfidence[category] ?? 0)) {
        strongestConfidence[category] = label.confidence;
      }
    }
  }

  String? bestCategory;
  var bestScore = 0.0;
  for (final category in reportCategories) {
    final score = scores[category] ?? 0;
    if (score > bestScore) {
      bestCategory = category;
      bestScore = score;
    }
  }
  if (bestCategory == null || bestScore < .35) return null;

  final evidence = (bestScore / 3).clamp(0.0, 1.0);
  final confidence =
      ((strongestConfidence[bestCategory] ?? 0) * .75 + evidence * .25).clamp(
        0.0,
        .99,
      );
  return (bestCategory, confidence);
}

List<String> reportCategoryOptions(String currentCategory) {
  if (currentCategory.isEmpty || reportCategories.contains(currentCategory)) {
    return reportCategories;
  }
  return [currentCategory, ...reportCategories];
}
