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

List<String> reportCategoryOptions(String currentCategory) {
  if (currentCategory.isEmpty || reportCategories.contains(currentCategory)) {
    return reportCategories;
  }
  return [currentCategory, ...reportCategories];
}
