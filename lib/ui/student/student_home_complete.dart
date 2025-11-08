import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/education_constants.dart';
import '../../utils/pink_theme.dart';
import '../../widgets/codeira_footer.dart';
import 'inbox_screen.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomeComplete extends StatefulWidget {
  const StudentHomeComplete({super.key});

  @override
  State<StudentHomeComplete> createState() => _StudentHomeCompleteState();
}

class _StudentHomeCompleteState extends State<StudentHomeComplete> {
  Map<String, dynamic>? _studentData;
  Map<String, String> _teacherNames = {}; // أسماء المعلمين حسب المادة
  Map<String, List<Map<String, dynamic>>> _activeHomeworks = {}; // الواجبات النشطة حسب المادة
  List<Map<String, dynamic>> _absenceNotifications = []; // إشعارات الغياب
  List<Map<String, dynamic>> _adminAnnouncements = []; // إشعارات الإدارة للبانر
  Set<String> _viewedHomeworks = {}; // المواد التي تم فتح واجباتها
  bool _isLoading = true;
  String? _errorMessage;
  
  // إشعارات محلية
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadViewedHomeworks(); // تحميل الواجبات المشاهدة من التخزين
    _loadStudentData();
    // _loadTeacherNames(); // سيتم استدعاؤها بعد تحميل بيانات الطالب
    // _loadActiveHomeworks(); // سيتم استدعاؤها بعد تحميل بيانات الطالب
    _listenToHomeworkNotifications(); // الاستماع للإشعارات الجديدة
    _listenToAbsenceNotifications(); // الاستماع لإشعارات الغياب الفورية
    _listenToAdminAnnouncements(); // الاستماع لإشعارات الإدارة الفورية
  }

  // الاستماع للإشعارات الجديدة
  void _listenToHomeworkNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('notifications_homeworks')
        .where('studentId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            // إشعار محلي
            _showLocalHomeworkNotification(data);
            
            // تحديث الواجبات
            _loadActiveHomeworks();
          }
        }
      }
    });
  }

  // عرض إشعار محلي للواجب مع صوت واهتزاز
  Future<void> _showLocalHomeworkNotification(Map<String, dynamic> data) async {
    try {
      final subjectName = data['subjectName'] ?? 'مادة';
      final subjectEmoji = data['subjectEmoji'] ?? '📚';
      final title = data['title'] ?? 'واجب جديد';
      
      // إعدادات Android مع صوت واهتزاز (يطابق notification_service.dart)
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'school_notifications_v2',
        'إشعارات المدرسة',
        channelDescription: 'إشعارات الواجبات والغياب والإدارة مع صوت واهتزاز',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableLights: true,
      );
      
      const NotificationDetails details = NotificationDetails(android: androidDetails);
      
      // عرض الإشعار مع صوت واهتزاز
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '$subjectEmoji واجب جديد',
        '$subjectName: $title',
        details,
      );
      
      print('✅ تم عرض إشعار: $subjectName');
    } catch (e) {
      print('⚠️ خطأ في عرض الإشعار: $e');
    }
  }

  // تحميل الواجبات المشاهدة من SharedPreferences
  Future<void> _loadViewedHomeworks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final key = 'viewed_homeworks_${user.uid}';
        final viewedList = prefs.getStringList(key) ?? [];
        setState(() {
          _viewedHomeworks = viewedList.toSet();
        });
        print('✅ تم تحميل ${_viewedHomeworks.length} واجب مشاهد');
      }
    } catch (e) {
      print('⚠️ خطأ في تحميل الواجبات المشاهدة: $e');
    }
  }

  // حفظ الواجبات المشاهدة في SharedPreferences
  Future<void> _saveViewedHomeworks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final key = 'viewed_homeworks_${user.uid}';
        await prefs.setStringList(key, _viewedHomeworks.toList());
        print('✅ تم حفظ ${_viewedHomeworks.length} واجب مشاهد');
      }
    } catch (e) {
      print('⚠️ خطأ في حفظ الواجبات المشاهدة: $e');
    }
  }

  Future<void> _loadStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'لم يتم تسجيل الدخول';
      });
      return;
    }

    try {
      print('=== تحميل بيانات الطالب ===');
      print('UID: ${user.uid}');
      
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      print('Document exists: ${doc.exists}');
      if (doc.exists) {
        print('Data: ${doc.data()}');
      }

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        setState(() {
          _studentData = doc.data();
          _isLoading = false;
        });
        
        // تحميل البيانات بعد تحميل بيانات الطالب
        _loadTeacherNames(); // ✅ تحميل أسماء المعلمين
        _loadActiveHomeworks();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'بيانات الطالب غير موجودة في قاعدة البيانات.\nالرجاء التواصل مع الإدارة.';
        });
      }
    } catch (e) {
      print('خطأ في تحميل بيانات الطالب: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ في تحميل البيانات: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadStudentData,
                  icon: const Icon(Icons.refresh),
                  label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PinkTheme.mainGradient,
        ),
        child: Stack(
          children: [
            // إيموجيات الخلفية
            Positioned(
              bottom: 20,
              left: 20,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  '📚',
                  style: TextStyle(fontSize: 80),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 30,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  '📖',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 50,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  '✏️',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 100,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  '📝',
                  style: TextStyle(fontSize: 70),
                ),
              ),
            ),
            
            // المحتوى الرئيسي
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75), // طبقة بيضاء شفافة
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                  
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // بطاقة الملف الشخصي
                        _buildProfileCard(),
                  
                  const SizedBox(height: 24),
                  
                  // إشعارات الغياب
                  if (_absenceNotifications.isNotEmpty) ...[
                    _buildAbsenceNotifications(),
                    const SizedBox(height: 24),
                  ],
                  
                  // إشعارات الإدارة
                  if (_adminAnnouncements.isNotEmpty) ...[
                    _buildAdminAnnouncementsBanner(),
                    const SizedBox(height: 24),
                  ],
                  
                  // عنوان المواد
                  Text(
                    'المواد الدراسية',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // شبكة المواد
                  _buildSubjectsGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // رسالة التشجيع
                  Center(
                    child: Text(
                      'بالتوفيق في دراستك! ⭐',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Footer
                  const Center(
                    child: CodeiraFooter(
                      fontSize: 14,
                      textColor: Color(0xFF4A8FA9),
                      codeiraColor: Color(0xFF4A8FA9),
                      hasUnderline: false,
                      hasShadow: false,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // الأزرار على اليسار
          Row(
            children: [
              // زر معلومات الحساب (أقصى اليسار)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB6AC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 24),
                  onPressed: () {
                    _showProfileBottomSheet(context);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // زر الإشعارات
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: PinkTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white, size: 24),
                  onPressed: () {
                    _showNotificationsMenu(context);
                  },
                ),
              ),
            ],
          ),
          
          // العنوان على اليمين
          Expanded(
            child: Text(
              'ثانوية دار السلام للبنات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // الاسم والدور
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _studentData?['name'] ?? 'الطالب',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: PinkTheme.cardGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'طالب',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // أيقونة الحساب
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: PinkTheme.buttonGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    _showProfileBottomSheet(context);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // الصف والشعبة
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: PinkTheme.cardGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: PinkTheme.pink2.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'الشعبة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _studentData?['section'] ?? '-',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 10),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: PinkTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: PinkTheme.purple1.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'الصف',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _studentData?['grade'] ?? '-',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAnnouncementsBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _adminAnnouncements.map((announcement) {
        final title = announcement['title'] as String? ?? 'إشعار';
        final message = announcement['message'] as String? ?? '';
        final type = announcement['type'] as String? ?? 'info';
        final timestamp = (announcement['timestamp'] as Timestamp?)?.toDate();
        final dateStr = timestamp != null 
            ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
            : 'غير محدد';
        
        // ألوان حسب النوع
        Color backgroundColor1, backgroundColor2, borderColor, iconColor;
        IconData icon;
        
        switch (type) {
          case 'success':
            backgroundColor1 = const Color(0xFFE8F5E9);
            backgroundColor2 = const Color(0xFFC8E6C9);
            borderColor = Colors.green[300]!;
            iconColor = Colors.green[700]!;
            icon = Icons.check_circle;
            break;
          case 'warning':
            backgroundColor1 = const Color(0xFFFFF3E0);
            backgroundColor2 = const Color(0xFFFFE0B2);
            borderColor = Colors.orange[300]!;
            iconColor = Colors.orange[700]!;
            icon = Icons.warning;
            break;
          case 'error':
            backgroundColor1 = const Color(0xFFFFEBEE);
            backgroundColor2 = const Color(0xFFFFCDD2);
            borderColor = Colors.red[300]!;
            iconColor = Colors.red[700]!;
            icon = Icons.error;
            break;
          default: // info
            backgroundColor1 = const Color(0xFFE3F2FD);
            backgroundColor2 = const Color(0xFFBBDEFB);
            borderColor = Colors.blue[300]!;
            iconColor = Colors.blue[700]!;
            icon = Icons.info;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundColor1, backgroundColor2],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAbsenceNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _absenceNotifications.map((absence) {
        final message = absence['message'] as String? ?? '';
        final date = (absence['date'] as Timestamp?)?.toDate();
        final dateStr = date != null 
            ? '${date.day}/${date.month}/${date.year}'
            : 'غير محدد';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'إشعار غياب',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectsGrid() {
    if (_studentData == null) return const SizedBox.shrink();

    // تحديد المواد حسب المرحلة والصف
    List<Map<String, dynamic>> subjects = [];
    
    final stage = _studentData!['stage'];
    final grade = _studentData!['grade'];
    final branch = _studentData!['branch'];

    if (stage == 'ابتدائية') {
      subjects = [
        {'name': 'التربية الإسلامية', 'icon': Icons.menu_book, 'color': const Color(0xFFFF9800)},
        {'name': 'اللغة العربية', 'icon': Icons.translate, 'color': const Color(0xFF26C6DA)},
        {'name': 'اللغة الإنكليزية', 'icon': Icons.language, 'color': const Color(0xFF9E9E9E)},
        {'name': 'الرياضيات', 'icon': Icons.calculate, 'color': const Color(0xFF2196F3)},
        {'name': 'العلوم', 'icon': Icons.science, 'color': const Color(0xFF4CAF50)},
        {'name': 'الرياضة', 'icon': Icons.sports_soccer, 'color': const Color(0xFFFF5722)},
        {'name': 'الفنية', 'icon': Icons.palette, 'color': const Color(0xFFE91E63)},
      ];
      
      // التربية الأخلاقية (الأول والثاني فقط)
      if (grade == 'الأول' || grade == 'الثاني') {
        subjects.add({'name': 'التربية الأخلاقية', 'icon': Icons.favorite, 'color': const Color(0xFFF44336)});
      }
      
      // الاجتماعيات (من الرابع إلى السادس)
      if (grade == 'الرابع' || grade == 'الخامس' || grade == 'السادس') {
        subjects.add({'name': 'الاجتماعيات', 'icon': Icons.public, 'color': const Color(0xFF8BC34A)});
      }
    } else if (stage == 'متوسطة') {
      subjects = [
        {'name': 'التربية الإسلامية', 'icon': Icons.menu_book, 'color': const Color(0xFFFF9800)},
        {'name': 'اللغة العربية', 'icon': Icons.translate, 'color': const Color(0xFF26C6DA)},
        {'name': 'اللغة الإنكليزية', 'icon': Icons.language, 'color': const Color(0xFF9E9E9E)},
        {'name': 'الاجتماعيات', 'icon': Icons.public, 'color': const Color(0xFF8BC34A)},
        {'name': 'الرياضيات', 'icon': Icons.calculate, 'color': const Color(0xFF2196F3)},
        {'name': 'الفيزياء', 'icon': Icons.bolt, 'color': const Color(0xFFFFEB3B)},
        {'name': 'الكيمياء', 'icon': Icons.science, 'color': const Color(0xFF9C27B0)},
        {'name': 'الأحياء', 'icon': Icons.biotech, 'color': const Color(0xFF4CAF50)},
        {'name': 'الحاسوب', 'icon': Icons.computer, 'color': const Color(0xFF607D8B)},
        {'name': 'التربية الفنية', 'icon': Icons.palette, 'color': const Color(0xFFE91E63)},
        {'name': 'التربية الرياضية', 'icon': Icons.sports_soccer, 'color': const Color(0xFFFF5722)},
      ];
      
      // التربية الأخلاقية (الأول والثاني فقط)
      if (grade == 'الأول' || grade == 'الثاني') {
        subjects.add({'name': 'التربية الأخلاقية', 'icon': Icons.favorite, 'color': const Color(0xFFF44336)});
      }
    } else if (stage == 'إعدادية') {
      if (branch == 'علمي') {
        subjects = [
          {'name': 'التربية الإسلامية', 'icon': Icons.menu_book, 'color': const Color(0xFFFF9800)},
          {'name': 'اللغة العربية', 'icon': Icons.translate, 'color': const Color(0xFF26C6DA)},
          {'name': 'اللغة الإنكليزية', 'icon': Icons.language, 'color': const Color(0xFF9E9E9E)},
          {'name': 'الرياضيات', 'icon': Icons.calculate, 'color': const Color(0xFF2196F3)},
          {'name': 'الفيزياء', 'icon': Icons.bolt, 'color': const Color(0xFFFFEB3B)},
          {'name': 'الكيمياء', 'icon': Icons.science, 'color': const Color(0xFF9C27B0)},
          {'name': 'الأحياء', 'icon': Icons.biotech, 'color': const Color(0xFF4CAF50)},
          {'name': 'التربية الرياضية', 'icon': Icons.sports_soccer, 'color': const Color(0xFFFF5722)},
          {'name': 'التربية الفنية', 'icon': Icons.palette, 'color': const Color(0xFFE91E63)},
        ];
        
        // جرائم حزب البعث (الرابع والخامس فقط)
        if (grade == 'الرابع' || grade == 'الخامس') {
          subjects.add({'name': 'جرائم حزب البعث', 'icon': Icons.gavel, 'color': const Color(0xFF795548)});
        }
        
        // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
        if (grade == 'الرابع' || grade == 'الخامس') {
          subjects.add({'name': 'الحاسوب', 'icon': Icons.computer, 'color': const Color(0xFF607D8B)});
        }
      } else {
        subjects = [
          {'name': 'التربية الإسلامية', 'icon': Icons.menu_book, 'color': const Color(0xFFFF9800)},
          {'name': 'اللغة العربية', 'icon': Icons.translate, 'color': const Color(0xFF26C6DA)},
          {'name': 'اللغة الإنكليزية', 'icon': Icons.language, 'color': const Color(0xFF9E9E9E)},
          {'name': 'التاريخ', 'icon': Icons.history_edu, 'color': const Color(0xFF795548)},
          {'name': 'الجغرافية', 'icon': Icons.map, 'color': const Color(0xFF009688)},
          {'name': 'الرياضيات', 'icon': Icons.calculate, 'color': const Color(0xFF2196F3)},
          {'name': 'التربية الرياضية', 'icon': Icons.sports_soccer, 'color': const Color(0xFFFF5722)},
          {'name': 'التربية الفنية', 'icon': Icons.palette, 'color': const Color(0xFFE91E63)},
        ];
        
        // جرائم حزب البعث (الرابع فقط)
        if (grade == 'الرابع') {
          subjects.add({'name': 'جرائم حزب البعث', 'icon': Icons.gavel, 'color': const Color(0xFF795548)});
        }
        
        // الاجتماع (الرابع فقط)
        if (grade == 'الرابع') {
          subjects.add({'name': 'الاجتماع', 'icon': Icons.groups, 'color': const Color(0xFF00BCD4)});
        }
        
        // الاقتصاد (الخامس والسادس فقط)
        if (grade == 'الخامس' || grade == 'السادس') {
          subjects.add({'name': 'الاقتصاد', 'icon': Icons.attach_money, 'color': const Color(0xFF4CAF50)});
        }
        
        // الفلسفة وعلم النفس (الخامس فقط)
        if (grade == 'الخامس') {
          subjects.add({'name': 'الفلسفة وعلم النفس', 'icon': Icons.psychology, 'color': const Color(0xFF673AB7)});
        }
        
        // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
        if (grade == 'الرابع' || grade == 'الخامس') {
          subjects.add({'name': 'الحاسوب', 'icon': Icons.computer, 'color': const Color(0xFF607D8B)});
        }
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.65, // زيادة الارتفاع لاستيعاب اسم المادة واسم المعلم
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  // بطاقة المادة مع الواجب التفاعلي
  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final subjectName = subject['name'] as String;
    final hasHomework = _hasActiveHomework(subjectName);
    final teacherName = _getTeacherName(subjectName);
    
    // طباعة تشخيصية
    if (hasHomework) {
      print('✅ المادة "$subjectName" لديها واجب نشط');
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showHomeworkDialog(subjectName);
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75), // تأثير زجاجي
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (subject['color'] as Color).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // المحتوى
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    // الأيقونة في المنتصف
                    Icon(
                      subject['icon'] as IconData,
                      color: subject['color'] as Color,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    // اسم المادة في المنتصف
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          subjectName,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: subject['color'] as Color,
                            height: 1.15,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // اسم المعلم
                    Text(
                      'أ : $teacherName',
                      style: GoogleFonts.cairo(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: (subject['color'] as Color).withOpacity(0.7),
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
              // شارة الواجب الجديد
              if (hasHomework && !_viewedHomeworks.contains(subjectName))
                Positioned(
                  top: 6,
                  left: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'واجب جديد',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // تحميل أسماء المعلمين من Firestore
  Future<void> _loadTeacherNames() async {
    if (_studentData == null) {
      print('❌ _studentData == null في _loadTeacherNames');
      return;
    }
    
    try {
      final stage = _studentData!['stage'] as String?;
      final grade = _studentData!['grade'] as String?;
      final branch = _studentData!['branch'] as String?;
      final section = _studentData!['section'] as String?;

      print('📊 بيانات الطالب: stage=$stage, grade=$grade, branch=$branch, section=$section');

      if (stage == null || grade == null || section == null) {
        print('⚠️ بيانات الطالب غير كاملة');
        return;
      }

      // جلب المواد حسب بيانات الطالب
      Query query = FirebaseFirestore.instance
          .collection('subjects')
          .where('stage', isEqualTo: stage)
          .where('grade', isEqualTo: grade);

      // إضافة الفرع للإعدادية
      if (stage == 'إعدادية' && branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final subjectsSnapshot = await query.get();
      print('📚 عدد المواد المسترجعة: ${subjectsSnapshot.docs.length}');

      final Map<String, String> names = {};
      
      for (var doc in subjectsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final subjectName = data['name'] as String?;
        final teacherName = data['teacherName'] as String?;
        final teacherId = data['teacherId'] as String?;
        final sections = data['sections'] as List<dynamic>?;
        
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔍 مادة: $subjectName');
        print('   teacherName: $teacherName');
        print('   teacherId: $teacherId');
        print('   sections: $sections');
        print('   document ID: ${doc.id}');
        
        // تحقق من أن المادة للشعبة الصحيحة
        if (sections != null && !sections.contains(section)) {
          print('⏭️ تخطي $subjectName - ليست للشعبة $section');
          continue;
        }
        
        if (subjectName != null) {
          // إذا كان teacherName موجود، استخدمه
          if (teacherName != null && teacherName.isNotEmpty) {
            names[subjectName] = teacherName;
            print('✅ اسم المعلم من subjects: $subjectName → $teacherName');
          }
          // إذا لم يكن موجود لكن teacherId موجود، جلب الاسم من users
          else if (teacherId != null && teacherId.isNotEmpty) {
            try {
              print('🔄 جلب اسم المعلم من users لـ $subjectName (teacherId: $teacherId)');
              final teacherDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(teacherId)
                  .get();
              
              if (teacherDoc.exists) {
                final name = teacherDoc.data()?['name'] as String?;
                if (name != null && name.isNotEmpty) {
                  names[subjectName] = name;
                  print('✅ جلب اسم المعلم من users: $subjectName → $name');
                } else {
                  print('⚠️ اسم المعلم فارغ في users لـ $subjectName');
                }
              } else {
                print('⚠️ وثيقة المعلم غير موجودة في users: $teacherId');
              }
            } catch (e) {
              print('⚠️ خطأ في جلب معلم $subjectName: $e');
            }
          } else {
            print('⚠️ لا يوجد teacherName ولا teacherId لـ $subjectName');
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _teacherNames = names;
        });
      }
      
      print('✅ تم تحميل ${names.length} اسم معلم من ${subjectsSnapshot.docs.length} مادة');
      print('📋 الأسماء المحملة: $names');
    } catch (e) {
      print('❌ خطأ في تحميل أسماء المعلمين: $e');
    }
  }

  // الحصول على اسم المعلم للمادة
  String _getTeacherName(String subjectName) {
    return _teacherNames[subjectName] ?? 'غير محدد';
  }

  // تحميل الواجبات النشطة من Firestore (24 ساعة فقط)
  Future<void> _loadActiveHomeworks() async {
    if (_studentData == null) return;

    try {
      final stage = _studentData!['stage'];
      final grade = _studentData!['grade'];
      final branch = _studentData!['branch'];
      final section = _studentData!['section'];
      
      print('🔍 البحث عن واجبات: stage=$stage, grade=$grade, branch=$branch, section=$section');
      
      // استخدام snapshots للاستماع للتغييرات الفورية
      Query query = FirebaseFirestore.instance
          .collection('homework')
          .where('stage', isEqualTo: stage)
          .where('grade', isEqualTo: grade)
          .where('sections', arrayContains: section);
      
      // إضافة الفرع للإعدادية
      if (stage == 'إعدادية' && branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }
      
      query.snapshots().listen((snapshot) {
        
        final now = DateTime.now();
        print('📚 تحديث الواجبات: ${snapshot.docs.length} واجب');

        final Map<String, List<Map<String, dynamic>>> homeworks = {};
        
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;
          
          final subjectName = data['subjectName'] as String?;
          final activeUntil = (data['activeUntil'] as Timestamp?)?.toDate();
          
          print('   📝 واجب: $subjectName, activeUntil: $activeUntil');
          
          // فلترة: activeUntil لم ينتهِ بعد (24 ساعة)
          if (subjectName != null && activeUntil != null && activeUntil.isAfter(now)) {
            if (!homeworks.containsKey(subjectName)) {
              homeworks[subjectName] = [];
            }
            homeworks[subjectName]!.add({
              'id': doc.id,
              ...data,
            });
            print('   ✅ تمت إضافة واجب: $subjectName');
          } else {
            print('   ❌ تم تجاهل واجب: $subjectName (منتهي أو null)');
          }
        }
        
        print('📚 عدد المواد التي لها واجبات نشطة: ${homeworks.length}');
        print('📋 أسماء المواد في الواجبات: ${homeworks.keys.toList()}');
        
        if (mounted) {
          setState(() {
            _activeHomeworks = homeworks;
          });
        }
      });
    } catch (e) {
      print('❌ خطأ في الاستماع للواجبات: $e');
    }
  }

  // الاستماع لإشعارات الغياب الفورية (مع صوت واهتزاز)
  void _listenToAbsenceNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    FirebaseFirestore.instance
        .collection('notifications_absences')
        .where('studentUid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, dynamic>> notifications = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bannerExpiresAt = (data['bannerExpiresAt'] as Timestamp?)?.toDate();
        
        // فلترة: البانر لم ينتهِ بعد (24 ساعة)
        if (bannerExpiresAt != null && bannerExpiresAt.isAfter(DateTime.now())) {
          notifications.add({
            'id': doc.id,
            ...data,
          });
        }
      }
      
      // إشعار محلي للإشعارات الجديدة
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _showLocalAbsenceNotification(data);
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _absenceNotifications = notifications;
        });
      }
    });
  }

  // عرض إشعار محلي للغياب مع صوت واهتزاز
  Future<void> _showLocalAbsenceNotification(Map<String, dynamic> data) async {
    try {
      final message = data['message'] ?? 'إشعار غياب';
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'school_notifications_v2',
        'إشعارات المدرسة',
        channelDescription: 'إشعارات الواجبات والغياب والإدارة مع صوت واهتزاز',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableLights: true,
      );
      
      const NotificationDetails details = NotificationDetails(android: androidDetails);
      
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '⚠️ إشعار غياب',
        message,
        details,
      );
      
      print('✅ تم عرض إشعار غياب: $message');
    } catch (e) {
      print('⚠️ خطأ في عرض إشعار الغياب: $e');
    }
  }

  // الاستماع لإشعارات الإدارة الفورية
  void _listenToAdminAnnouncements() {
    FirebaseFirestore.instance
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final now = DateTime.now();
      final List<Map<String, dynamic>> announcements = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bannerExpiresAt = (data['bannerExpiresAt'] as Timestamp?)?.toDate();
        final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
        final targetRole = data['targetRole'] as String?;
        
        // فلترة: بانر لم ينتهِ + لم ينتهِ بشكل عام + للطلاب أو الجميع
        if (bannerExpiresAt != null && 
            bannerExpiresAt.isAfter(now) &&
            expiresAt != null &&
            expiresAt.isAfter(now) &&
            (targetRole == 'all' || targetRole == 'student')) {
          announcements.add({
            'id': doc.id,
            ...data,
          });
        }
      }
      
      // إشعار محلي للإشعارات الجديدة
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            final targetRole = data['targetRole'] as String?;
            if (targetRole == 'all' || targetRole == 'student') {
              _showLocalAdminNotification(data);
            }
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _adminAnnouncements = announcements;
        });
      }
    });
  }

  // عرض إشعار محلي لإعلان الإدارة
  Future<void> _showLocalAdminNotification(Map<String, dynamic> data) async {
    try {
      final title = data['title'] ?? 'إعلان جديد';
      final message = data['message'] ?? '';
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'school_notifications_v2',
        'إشعارات المدرسة',
        channelDescription: 'إشعارات الواجبات والغياب والإدارة مع صوت واهتزاز',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableLights: true,
      );
      
      const NotificationDetails details = NotificationDetails(android: androidDetails);
      
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '📢 $title',
        message,
        details,
      );
      
      print('✅ تم عرض إشعار إداري: $title');
    } catch (e) {
      print('⚠️ خطأ في عرض الإشعار الإداري: $e');
    }
  }

  // التحقق من وجود واجب نشط للمادة
  bool _hasActiveHomework(String subjectName) {
    return _activeHomeworks.containsKey(subjectName) && 
           _activeHomeworks[subjectName]!.isNotEmpty;
  }

  // عرض نافذة الواجب
  void _showHomeworkDialog(String subjectName) {
    final homeworks = _activeHomeworks[subjectName] ?? [];
    
    // تعليم المادة كمفتوحة لإخفاء الشارة وحفظها
    setState(() {
      _viewedHomeworks.add(subjectName);
    });
    _saveViewedHomeworks(); // حفظ في التخزين المحلي
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'واجبات $subjectName',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // عرض الواجبات
              Flexible(
                child: homeworks.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد واجبات نشطة',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: homeworks.length,
                        itemBuilder: (context, index) {
                          final homework = homeworks[index];
                          final title = homework['title'] as String? ?? 'واجب';
                          final details = homework['details'] as String? ?? '';
                          final teacherName = homework['teacherName'] as String? ?? 'المعلم';
                          final createdAt = (homework['createdAt'] as Timestamp?)?.toDate();
                          final dateStr = createdAt != null
                              ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                              : 'غير محدد';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // العنوان
                                  Text(
                                    title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF3498DB),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // التفاصيل
                                  if (details.isNotEmpty) ...[
                                    Linkify(
                                      onOpen: (link) async {
                                        final uri = Uri.parse(link.url);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      text: details,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                      linkStyle: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: const Color(0xFF3498DB),
                                        decoration: TextDecoration.underline,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  
                                  // معلومات إضافية
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        teacherName,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض قائمة الإشعارات
  void _showNotificationsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // العنوان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: PinkTheme.pink2,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'الإشعارات',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // التبويبات
                TabBar(
                  labelColor: PinkTheme.pink2,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: PinkTheme.pink2,
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'الواجبات السابقة'),
                    Tab(text: 'إشعارات الإدارة'),
                    Tab(text: 'سجل الغيابات'),
                  ],
                ),
                
                // محتوى التبويبات
                Expanded(
                  child: TabBarView(
                    children: [
                      // تبويب الواجبات السابقة
                      _buildPreviousHomeworksTab(scrollController),
                      
                      // تبويب إشعارات الإدارة
                      _buildAdminNotificationsTab(scrollController),
                      
                      // تبويب سجل الغيابات
                      _buildAbsenceRecordTab(scrollController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تبويب الواجبات السابقة
  Widget _buildPreviousHomeworksTab(ScrollController scrollController) {
    final now = DateTime.now();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('homework')
          .where('stage', isEqualTo: _studentData!['stage'])
          .where('grade', isEqualTo: _studentData!['grade'])
          .where('sections', arrayContains: _studentData!['section'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ في تحميل الواجبات',
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final homeworks = snapshot.data?.docs ?? [];

        // فلترة حسب archiveUntil
        final filteredHomeworks = homeworks.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final archiveUntil = (data['archiveUntil'] as Timestamp?)?.toDate();
          return archiveUntil != null && archiveUntil.isAfter(now);
        }).toList();

        // ترتيب حسب التاريخ
        filteredHomeworks.sort((a, b) {
          final aTime = ((a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bTime = ((b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        if (filteredHomeworks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد واجبات سابقة',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: filteredHomeworks.length,
          itemBuilder: (context, index) {
            final homework = filteredHomeworks[index].data() as Map<String, dynamic>;
            final subjectName = homework['subjectName'] as String? ?? 'مادة';
            final title = homework['title'] as String? ?? '';
            final createdAt = (homework['createdAt'] as Timestamp?)?.toDate();
            final subjectEmoji = homework['subjectEmoji'] as String? ?? '📚';
            
            final dateStr = createdAt != null 
                ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                : 'غير محدد';
            
            // ألوان مختلفة للمواد
            final colors = [
              const Color(0xFF2196F3),
              const Color(0xFF26C6DA),
              const Color(0xFF9C27B0),
              const Color(0xFF4CAF50),
              const Color(0xFFFF9800),
            ];
            final color = colors[index % colors.length];

            return _buildPreviousHomeworkItem(
              '$subjectEmoji $subjectName',
              title,
              dateStr,
              color,
            );
          },
        );
      },
    );
  }

  // تبويب إشعارات الإدارة
  Widget _buildAdminNotificationsTab(ScrollController scrollController) {
    final now = DateTime.now();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ في تحميل الإشعارات',
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final announcements = snapshot.data?.docs ?? [];

        if (announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد إشعارات',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // فلترة الإشعارات حسب التاريخ والدور
        final filteredAnnouncements = announcements.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
          final targetRole = data['targetRole'] as String?;
          
          // فلترة حسب التاريخ والدور
          return expiresAt != null && 
                 expiresAt.isAfter(now) && 
                 (targetRole == 'all' || targetRole == 'student');
        }).toList();

        if (filteredAnnouncements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد إشعارات',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: filteredAnnouncements.length,
          itemBuilder: (context, index) {
            final announcement = filteredAnnouncements[index].data() as Map<String, dynamic>;
            final title = announcement['title'] as String? ?? 'إشعار';
            final message = announcement['message'] as String? ?? '';
            final timestamp = (announcement['timestamp'] as Timestamp?)?.toDate();
            final type = announcement['type'] as String? ?? 'info';
            
            final dateStr = timestamp != null 
                ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
                : 'غير محدد';
            
            IconData icon;
            switch (type) {
              case 'success':
                icon = Icons.check_circle;
                break;
              case 'warning':
                icon = Icons.warning;
                break;
              case 'error':
                icon = Icons.error;
                break;
              default:
                icon = Icons.info;
            }

            return _buildAdminNotificationItem(title, message, dateStr, icon);
          },
        );
      },
    );
  }

  // تبويب سجل الغيابات
  Widget _buildAbsenceRecordTab(ScrollController scrollController) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications_absences')
          .where('studentUid', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ في تحميل سجل الغيابات',
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final absences = snapshot.data?.docs ?? [];

        // فلترة حسب archiveUntil
        final filteredAbsences = absences.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final archiveUntil = (data['archiveUntil'] as Timestamp?)?.toDate();
          return archiveUntil != null && archiveUntil.isAfter(now);
        }).toList();

        if (filteredAbsences.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد سجلات غياب',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // ترتيب حسب التاريخ
        filteredAbsences.sort((a, b) {
          final aTime = ((a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bTime = ((b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: filteredAbsences.length,
          itemBuilder: (context, index) {
            final absence = filteredAbsences[index].data() as Map<String, dynamic>;
            final message = absence['message'] as String? ?? '';
            final date = (absence['date'] as Timestamp?)?.toDate();
            final bannerExpiresAt = (absence['bannerExpiresAt'] as Timestamp?)?.toDate();
            
            final dateStr = date != null 
                ? '${date.day}/${date.month}/${date.year}'
                : 'غير محدد';
            
            final isRecent = bannerExpiresAt != null && 
                             DateTime.now().isBefore(bannerExpiresAt);

            return _buildAbsenceRecordItem(
              dateStr,
              isRecent ? 'جديد' : 'قديم',
              message,
              isRecent ? Colors.red : Colors.orange,
            );
          },
        );
      },
    );
  }

  // عنصر إشعار الإدارة
  Widget _buildAdminNotificationItem(
    String title,
    String message,
    String date,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: PinkTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PinkTheme.pink2.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عنصر سجل الغياب
  Widget _buildAbsenceRecordItem(
    String date,
    String status,
    String reason,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'التاريخ: $date',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                if (reason != '-') ...[
                  const SizedBox(height: 4),
                  Text(
                    'السبب: $reason',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عنصر الواجب السابق
  Widget _buildPreviousHomeworkItem(
    String subject,
    String homework,
    String date,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subject,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            homework,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض نافذة الملف الشخصي
  void _showProfileBottomSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // معلومات الطالب
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DD0E1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentData?['name'] ?? 'الطالب',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // معلومات إضافية
            _buildProfileInfoRow(Icons.school, 'المرحلة', _studentData?['stage'] ?? '-'),
            const SizedBox(height: 12),
            _buildProfileInfoRow(Icons.class_, 'الصف', _studentData?['grade'] ?? '-'),
            const SizedBox(height: 12),
            _buildProfileInfoRow(Icons.people, 'الشعبة', _studentData?['section'] ?? '-'),
            
            const SizedBox(height: 24),
            
            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4DD0E1), size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    // عرض حوار التأكيد
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
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login_new',
          (route) => false,
        );
      }
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }

}
