class StudentModel {
  final String uid;
  final String email;
  final String name;
  final String stage;
  final String grade;
  final String? branch;
  final String section;
  final DateTime? createdAt;

  StudentModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.stage,
    required this.grade,
    this.branch,
    required this.section,
    this.createdAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      stage: map['stage'] ?? '',
      grade: map['grade'] ?? '',
      branch: map['branch'],
      section: map['section'] ?? '',
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
      'section': section,
      'createdAt': createdAt,
    };
  }
}
