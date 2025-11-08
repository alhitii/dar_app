class HomeworkModel {
  final String id;
  final String teacherId;
  final String subjectId;
  final String subjectName;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String stage;
  final String grade;
  final String? branch;
  final String section;

  HomeworkModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.stage,
    required this.grade,
    this.branch,
    required this.section,
  });

  factory HomeworkModel.fromMap(String id, Map<String, dynamic> map) {
    return HomeworkModel(
      id: id,
      teacherId: map['teacherId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as dynamic).toDate(),
      createdAt: (map['createdAt'] as dynamic).toDate(),
      stage: map['stage'] ?? '',
      grade: map['grade'] ?? '',
      branch: map['branch'],
      section: map['section'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'stage': stage,
      'grade': grade,
      'branch': branch,
      'section': section,
    };
  }
}
