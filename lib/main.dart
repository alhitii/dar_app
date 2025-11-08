import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'firebase_options.dart';
import 'theme/material3_theme.dart';
import 'ui/login_screen_perfect.dart';
import 'ui/login_screen_new.dart';
import 'ui/admin/admin_tabs_screen.dart';
import 'ui/teacher/teacher_home_complete.dart';
import 'ui/student/student_home_complete.dart';
import 'ui/student/student_home_new.dart';
import 'services/notification_service.dart';

// معالج الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔔 رسالة في الخلفية: ${message.notification?.title}');
  // سيتم معالجة الإشعار تلقائياً من قبل النظام
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // تسجيل معالج الرسائل في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
  
  // ✅ تهيئة خدمة الإشعارات بعد runApp (طريقة المشروع القديم)
  _postInit();
}

// تشغيل العمليات الثانوية بالخلفية
Future<void> _postInit() async {
  try {
    await NotificationService.instance.initialize();
    print('✅ NotificationService initialized');
  } catch (e) {
    print('⚠️ Notification init error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = '/login_new';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // ✅ تأخير أطول للسماح لـ Firebase بالتحميل الكامل على Windows
      await Future.delayed(const Duration(seconds: 1));
      
      User? user;
      
      // ✅ محاولات متعددة للحصول على المستخدم الحالي
      for (int i = 0; i < 3; i++) {
        user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          print('✅ تم العثور على مستخدم في المحاولة ${i + 1}');
          break;
        }
        print('⚠️ محاولة ${i + 1}: لا يوجد مستخدم، انتظار 500ms...');
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('🔍 فحص حالة المصادقة: ${user != null ? "مسجل (${user.email})" : "غير مسجل"}');
      
      if (user != null) {
        // جلب دور المستخدم من Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'student';
          
          print('✅ الدور: $role');
          
          // تحديد الصفحة الأولية حسب الدور
          if (role == 'admin') {
            _initialRoute = '/admin';
          } else if (role == 'teacher') {
            _initialRoute = '/teacher';
          } else {
            _initialRoute = '/student';
          }
        }
      } else {
        print('⚠️ لا يوجد مستخدم مسجل بعد 3 محاولات - الانتقال لصفحة تسجيل الدخول');
      }
    } catch (e) {
      print('❌ خطأ في فحص حالة المصادقة: $e');
      _initialRoute = '/login_new';
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF87CEEB), Color(0xFFFFB6C1)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // 🎨 تطبيق Dynamic Color مع Material 3
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // استخدام الألوان الديناميكية إذا كانت متوفرة، وإلا استخدام ألوان Codeira
        ColorScheme lightColorScheme = lightDynamic ?? Material3Theme.lightColorScheme;
        ColorScheme darkColorScheme = darkDynamic ?? Material3Theme.darkColorScheme;
        
        return MaterialApp(
          title: 'مدرسة دار السلام للبنات',
          debugShowCheckedModeBanner: false,
          
          // RTL Support
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'IQ'),
          ],
          locale: const Locale('ar', 'IQ'),
          
          // 🎨 Material 3 Theme - أسلوب Google الحديث
          theme: Material3Theme.lightTheme.copyWith(
            colorScheme: lightColorScheme,
          ),
          darkTheme: Material3Theme.darkTheme.copyWith(
            colorScheme: darkColorScheme,
          ),
          themeMode: ThemeMode.light, // يمكن التبديل للوضع الداكن
          
          // Routes
          initialRoute: _initialRoute,
          routes: {
            '/login': (context) => const LoginScreenPerfect(),
            '/login_new': (context) => const LoginScreenNew(),
            '/admin': (context) => const AdminTabsScreen(),
            '/teacher': (context) => const TeacherHomeComplete(),
            '/student': (context) => const StudentHomeComplete(),
            '/student_new': (context) => const StudentHomeNew(),
          },
        );
      },
    );
  }
}
