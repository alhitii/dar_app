class TeacherModel {
  final String uid;
  final String email;
  final String name;
  final String stage;
  final String grade;
  final String? branch;
  final List<String> sections;
  final List<String> subjects;
  final DateTime? createdAt;

  TeacherModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.stage,
    required this.grade,
    this.branch,
    required this.sections,
    required this.subjects,
    this.createdAt,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      stage: map['stage'] ?? '',
      grade: map['grade'] ?? '',
      branch: map['branch'],
      sections: List<String>.from(map['sections'] ?? []),
      subjects: List<String>.from(map['subjects'] ?? []),
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'stage': stage,
      'grade': grade,
      'branch': branch,
      'sections': sections,
      'subjects': subjects,
      'createdAt': createdAt,
    };
  }
}
