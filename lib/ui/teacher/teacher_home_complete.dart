import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/school_theme.dart';
import '../../utils/pink_theme.dart';
import '../../utils/app_colors.dart';
import '../../constants/education_constants.dart';
import '../student/inbox_screen.dart';
import 'teacher_profile_card.dart';

class TeacherHomeComplete extends StatefulWidget {
  const TeacherHomeComplete({super.key});

  @override
  State<TeacherHomeComplete> createState() => _TeacherHomeCompleteState();
}

class _TeacherHomeCompleteState extends State<TeacherHomeComplete> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  
  String? _selectedSubject;
  String? _selectedStage;
  String? _selectedGrade;
  String? _selectedBranch;
  List<String> _selectedSections = [];
  bool _isLoading = false;
  Map<String, dynamic>? _teacherData;
  List<Map<String, String>>? _teacherSubjects;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeacherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // ✅ استخدام snapshots للاستماع للتغييرات المباشرة في بيانات المعلم
      FirebaseFirestore.instance
          .collection('teachers')
          .doc(user.uid)
          .snapshots()
          .listen((teacherDoc) {
        
        if (!mounted) return;

        if (teacherDoc.exists) {
          final data = teacherDoc.data();
          setState(() {
            _teacherData = data;
            _loadTeacherSubjects();
          });
          print('✅ تم تحديث بيانات المعلم');
        } else {
          // إذا لم يوجد في teachers، جرب users
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .then((userDoc) {
            if (userDoc.exists && mounted) {
              setState(() {
                _teacherData = userDoc.data();
                _loadTeacherSubjects();
              });
            }
          });
        }
      });
    } catch (e) {
      print('خطأ في تحميل بيانات المعلم: $e');
    }
  }

  void _loadTeacherSubjects() {
    if (_teacherData == null) return;

    print('🔍 تحميل مواد المعلم من teacherData');

    // الحصول على المواد من teacherData['subjects']
    final subjects = _teacherData!['subjects'] as List<dynamic>?;
    
    if (subjects != null && subjects.isNotEmpty) {
      final subjectsList = <Map<String, String>>[];
      
      print('📚 عدد المواد: ${subjects.length}');
      
      for (var subjectName in subjects) {
        final name = subjectName.toString();
        
        // الحصول على الإيموجي من education_constants
        String emoji = '📚';
        final allSubjects = [
          ...EducationConstants.primarySchoolSubjects,
          ...EducationConstants.middleSchoolSubjects,
          ...EducationConstants.preparatoryCommonSubjects,
          ...EducationConstants.subjectsPreparatoryScience,
          ...EducationConstants.subjectsPreparatoryLiterature,
        ];
        
        for (var subject in allSubjects) {
          if (subject['name'] == name) {
            emoji = subject['emoji'] ?? '📚';
            break;
          }
        }
        
        subjectsList.add({
          'name': name,
          'code': name, // استخدام الاسم كـ code
          'emoji': emoji,
        });
        
        print('✅ مادة: $name ($emoji)');
      }
      
      setState(() {
        _teacherSubjects = subjectsList;
      });
      
      print('✅ تم تحميل ${subjectsList.length} مادة');
    } else {
      print('⚠️ لا توجد مواد في teacherData[\'subjects\']');
      setState(() {
        _teacherSubjects = [];
      });
    }
  }

  // إرسال إشعارات للطلاب
  Future<void> _sendNotificationsToStudents({
    required String subjectName,
    required String subjectEmoji,
    required String title,
  }) async {
    try {
      if (_selectedStage == null || _selectedGrade == null) {
        print('❌ يجب اختيار المرحلة والصف');
        return;
      }
      
      print('📚 إرسال واجب: $subjectName');
      print('🎯 المستهدف: $_selectedStage - $_selectedGrade${_selectedBranch != null ? " - $_selectedBranch" : ""}');
      print('📋 الشعب: ${_selectedSections.join(", ")}');
      
      // جلب جميع الطلاب في نفس المرحلة والصف
      Query studentsQuery = FirebaseFirestore.instance
          .collection('students')
          .where('stage', isEqualTo: _selectedStage)
          .where('grade', isEqualTo: _selectedGrade);
      
      // إضافة الفرع للإعدادية
      if (_selectedBranch != null && _selectedBranch!.isNotEmpty) {
        studentsQuery = studentsQuery.where('branch', isEqualTo: _selectedBranch);
      }
      
      final studentsSnapshot = await studentsQuery.get();
      print('👥 عدد الطلاب في الصف: ${studentsSnapshot.docs.length}');

      int notificationCount = 0;
      
      for (var studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        final studentSection = studentData['section'] as String?;
        
        // التحقق من أن الطالب في إحدى الشعب المختارة
        if (studentSection != null && _selectedSections.contains(studentSection)) {
          // إنشاء إشعار للطالب
          await FirebaseFirestore.instance
              .collection('notifications_homeworks')
              .add({
            'studentId': studentDoc.id,
            'teacherId': FirebaseAuth.instance.currentUser!.uid,
            'teacherName': _teacherData!['name'],
            'subjectName': subjectName,
            'subjectEmoji': subjectEmoji,
            'title': title,
            'type': 'homework',
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          notificationCount++;
        }
      }
      
      print('✅ تم إرسال $notificationCount إشعار للطلاب');
    } catch (e) {
      print('⚠️ خطأ في إرسال الإشعارات: $e');
    }
  }

  Future<void> _sendHomework() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المرحلة')),
      );
      return;
    }
    
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الصف')),
      );
      return;
    }
    
    if (_selectedStage == 'إعدادية' && _selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفرع')),
      );
      return;
    }
    
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المادة')),
      );
      return;
    }

    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار شعبة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // الحصول على تفاصيل المادة من _teacherSubjects
      // _selectedSubject هو اسم المادة مباشرة
      final selectedSubjectData = _teacherSubjects?.firstWhere(
        (subject) => subject['name'] == _selectedSubject,
        orElse: () => <String, String>{},
      );
      
      final subjectName = _selectedSubject ?? 'غير معروف';
      final subjectEmoji = selectedSubjectData?['emoji'] ?? '📚';
      
      print('📚 إرسال واجب: $subjectName ($subjectEmoji)');
      
      final now = DateTime.now();
      
      // إنشاء الواجب
      await FirebaseFirestore.instance.collection('homework').add({
        'teacherId': user.uid,
        'teacherName': _teacherData!['name'],
        'subjectCode': _selectedSubject,
        'subjectName': subjectName,
        'subjectEmoji': subjectEmoji,
        'title': _titleController.text,
        'details': _detailsController.text,
        'stage': _selectedStage, // ✅ استخدام القيمة المختارة
        'grade': _selectedGrade, // ✅ استخدام القيمة المختارة
        'branch': _selectedBranch, // ✅ استخدام القيمة المختارة
        'sections': _selectedSections, // الشعب المختارة فقط
        'createdAt': FieldValue.serverTimestamp(),
        'activeUntil': Timestamp.fromDate(now.add(const Duration(hours: 24))),  // يظهر في تبويب المادة لمدة 24 ساعة
        'archiveUntil': Timestamp.fromDate(now.add(const Duration(days: 365))), // يبقى في الواجبات السابقة لمدة سنة
        'dueDate': Timestamp.fromDate(now.add(const Duration(days: 7))),        // موعد نهائي بعد أسبوع
      });

      // إرسال إشعارات للطلاب
      await _sendNotificationsToStudents(
        subjectName: subjectName,
        subjectEmoji: subjectEmoji,
        title: _titleController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال الواجب والإشعارات بنجاح')),
      );

      // مسح الحقول
      _titleController.clear();
      _detailsController.clear();
      setState(() {
        _selectedSubject = null;
        _selectedSections.clear();
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PinkTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // TabBar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: PinkTheme.pink2,
                  unselectedLabelColor: const Color(0xFF7F8C8D),
                  indicatorColor: PinkTheme.pink2,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.cairo(
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.add_task),
                      text: 'إرسال واجب',
                    ),
                    Tab(
                      icon: Icon(Icons.list_alt),
                      text: 'الواجبات المرسلة',
                    ),
                  ],
                ),
              ),
              
              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // تبويب إرسال واجب
                    _buildSendHomeworkTab(),
                    
                    // تبويب الواجبات المرسلة
                    _buildSentHomeworkTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendHomeworkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بطاقة معلومات المعلم
          buildTeacherProfileCard(
            teacherData: _teacherData,
            teacherSubjects: _teacherSubjects,
          ),
          
          const SizedBox(height: 20),
          
          // مواد المعلم
          _buildSubjectsCard(),
          
          const SizedBox(height: 20),
          
          // إرسال واجب
          _buildHomeworkCard(),
          
          const SizedBox(height: 20),
          
          // جملة تحفيزية
          const Center(
            child: Text(
              '🎯 يوم دراسي موفق!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Footer
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.white70),
                children: [
                  TextSpan(text: 'Developed by '),
                  TextSpan(
                    text: 'Codeira',
                    style: TextStyle(
                      color: AppColors.buttonPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentHomeworkTab() {
    final user = FirebaseAuth.instance.currentUser;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('homework')
          .where('teacherId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: AppColors.iconSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'لا توجد واجبات مرسلة',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // ترتيب الواجبات حسب التاريخ
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); // الأحدث أولاً
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['createdAt'] as Timestamp?;
            String dateStr = '';
            if (timestamp != null) {
              final date = timestamp.toDate();
              dateStr = '${date.year}/${date.month}/${date.day}';
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.buttonPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: AppColors.buttonPrimary,
                  ),
                ),
                title: Text(
                  data['title'] ?? 'واجب',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'الصف: ${data['grade'] ?? '-'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'الشعب: ${(data['sections'] as List?)?.join(', ') ?? '-'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text('هل تريد حذف هذا الواجب؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      await doc.reference.delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حذف الواجب'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // الصورة الشخصية
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: PinkTheme.buttonGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // الاسم والمدرسة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ثانوية دار السلام للبنات',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                if (_teacherData != null)
                  Text(
                    'أ : ${_teacherData!['name']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
              ],
            ),
          ),
          // أيقونة الإشعارات
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: PinkTheme.pink2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxScreen()),
              );
            },
          ),
          // زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _confirmLogout(context),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard() {
    print('🎨 عرض بطاقة المواد: _teacherSubjects = ${_teacherSubjects?.length ?? 0}');
    if (_teacherSubjects != null) {
      for (var subject in _teacherSubjects!) {
        print('   📝 مادة في البطاقة: ${subject['name']} (${subject['emoji']})');
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const Row(
            children: [
              Icon(Icons.book, color: AppColors.iconPrimary),
              SizedBox(width: 8),
              Text(
                'مواد المعلم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // قائمة المواد
          if (_teacherSubjects == null || _teacherSubjects!.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.school, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد مواد مخصصة بعد',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _teacherSubjects!.map((subject) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subject['emoji'] ?? '📚',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subject['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            const Row(
              children: [
                Icon(Icons.assignment, color: AppColors.iconPrimary),
                SizedBox(width: 8),
                Text(
                  'إرسال واجب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // اختيار المرحلة
            DropdownButtonFormField<String>(
              value: _selectedStage,
              decoration: InputDecoration(
                labelText: 'اختر المرحلة',
                prefixIcon: const Icon(Icons.school, color: AppColors.iconPrimary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: (_teacherData?['stages'] as List<dynamic>?)?.map((stage) {
                return DropdownMenuItem(
                  value: stage.toString(),
                  child: Text(stage.toString()),
                );
              }).toList() ?? [],
              onChanged: (value) {
                setState(() {
                  _selectedStage = value;
                  _selectedGrade = null;
                  _selectedBranch = null;
                  _selectedSections = [];
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // اختيار الصف
            if (_selectedStage != null)
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: InputDecoration(
                  labelText: 'اختر الصف',
                  prefixIcon: const Icon(Icons.class_, color: AppColors.iconPrimary),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: (_teacherData?['grades'] as List<dynamic>?)?.map((grade) {
                  return DropdownMenuItem(
                    value: grade.toString(),
                    child: Text(grade.toString()),
                  );
                }).toList() ?? [],
                onChanged: (value) {
                  setState(() {
                    _selectedGrade = value;
                    _selectedBranch = null;
                    _selectedSections = [];
                  });
                },
              ),
            
            const SizedBox(height: 16),
            
            // اختيار الفرع (للإعدادية فقط)
            if (_selectedStage == 'إعدادية' && _selectedGrade != null)
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: InputDecoration(
                  labelText: 'اختر الفرع',
                  prefixIcon: const Icon(Icons.account_tree, color: AppColors.iconPrimary),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: (_teacherData?['branches'] as List<dynamic>?)?.map((branch) {
                  return DropdownMenuItem(
                    value: branch.toString(),
                    child: Text(branch.toString()),
                  );
                }).toList() ?? [],
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
                    _selectedSections = [];
                  });
                },
              ),
            
            if (_selectedStage == 'إعدادية' && _selectedGrade != null)
              const SizedBox(height: 16),
            
            // اختيار المادة
            if (_selectedGrade != null)
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'اختر المادة',
                  prefixIcon: const Icon(Icons.book, color: AppColors.iconPrimary),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _teacherSubjects?.map((subject) {
                  return DropdownMenuItem(
                    value: subject['name'],
                    child: Row(
                      children: [
                        Text(
                          subject['emoji'] ?? '📚',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(subject['name'] ?? ''),
                      ],
                    ),
                  );
                }).toList() ?? [],
                onChanged: (value) {
                  setState(() => _selectedSubject = value);
                },
              ),
            
            if (_selectedGrade != null)
              const SizedBox(height: 16),
            
            // اختيار الشعب
            if (_selectedGrade != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر الشعب المراد إرسال الواجب لها:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_teacherData?['sections'] as List<dynamic>?)?.map((section) {
                      final sectionStr = section.toString();
                      final isSelected = _selectedSections.contains(sectionStr);
                      return FilterChip(
                        label: Text('شعبة $sectionStr'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSections.add(sectionStr);
                            } else {
                              _selectedSections.remove(sectionStr);
                            }
                          });
                        },
                        selectedColor: AppColors.buttonPrimary.withOpacity(0.3),
                        checkmarkColor: AppColors.buttonPrimary,
                        backgroundColor: AppColors.inputFill,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.buttonPrimary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList() ?? [],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            // عنوان الواجب
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان الواجب ✏️',
                prefixIcon: const Icon(Icons.title, color: AppColors.iconPrimary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال عنوان الواجب';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // تفاصيل الواجب
            TextFormField(
              controller: _detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'تفاصيل الواجب 📄',
                prefixIcon: const Icon(Icons.description, color: AppColors.iconPrimary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال تفاصيل الواجب';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendHomework,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إرسال الواجب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تأكيد تسجيل الخروج
  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login_new');
      }
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }
}
