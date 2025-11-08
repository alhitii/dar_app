class SubjectModel {
  final String id;
  final String name;
  final String emoji;
  final String stage;
  final String grade;
  final String? branch;
  final String? section;

  SubjectModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.stage,
    required this.grade,
    this.branch,
    this.section,
  });

  factory SubjectModel.fromMap(String id, Map<String, dynamic> map) {
    return SubjectModel(
      id: id,
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '',
      stage: map['stage'] ?? '',
      grade: map['grade'] ?? '',
      branch: map['branch'],
      section: map['section'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'stage': stage,
      'grade': grade,
      'branch': branch,
      'section': section,
    };
  }
}
