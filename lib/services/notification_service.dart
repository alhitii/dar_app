import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _firebaseMessaging;

  // تحقق من دعم Firebase Messaging
  bool get _isMessagingSupported {
    if (kIsWeb) return true;
    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }

  // تهيئة الخدمة
  Future<void> initialize() async {
    print('🔔 تهيئة خدمة الإشعارات...');
    
    // إنشاء قناة الإشعارات على Android
    await _createNotificationChannel();
    
    // تهيئة Firebase Messaging فقط على المنصات المدعومة
    if (_isMessagingSupported) {
      try {
        _firebaseMessaging = FirebaseMessaging.instance;
        await _requestPermissions();
        
        // الاستماع للإشعارات عندما يكون التطبيق مفتوحاً
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // الاستماع عندما يفتح المستخدم الإشعار
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

        // الحصول على الرسالة التي فتحت التطبيق (إذا كان مغلقاً)
        RemoteMessage? initialMessage = await _firebaseMessaging!.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationOpen(initialMessage);
        }
        
        print('✅ Firebase Messaging مفعّل');
      } catch (e) {
        print('⚠️ Firebase Messaging غير مدعوم على هذه المنصة: $e');
      }
    } else {
      print('⚠️ Firebase Messaging غير مدعوم على Windows');
    }

    // إعدادات الإشعارات المحلية
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      print('✅ الإشعارات المحلية مفعّلة');
    } catch (e) {
      print('⚠️ الإشعارات المحلية غير مدعومة: $e');
    }
  }

  // إنشاء قناة الإشعارات
  Future<void> _createNotificationChannel() async {
    try {
      // ✅ حذف القنوات القديمة
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannel('high_importance_channel');
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannel('default_channel');
      
      // ✅ إنشاء قناة جديدة باسم مختلف (لإجبار Android على إنشاء قناة جديدة)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'school_notifications_v2', // ✅ اسم جديد
        'إشعارات المدرسة',
        description: 'إشعارات الواجبات والغياب والإدارة مع صوت واهتزاز',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      print('✅ قناة الإشعارات تم إنشاؤها: school_notifications_v2');
    } catch (e) {
      print('⚠️ خطأ في إنشاء قناة الإشعارات: $e');
    }
  }

  // طلب الأذونات
  Future<void> _requestPermissions() async {
    if (_firebaseMessaging == null) return;
    
    try {
      await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      
      // طباعة FCM Token للتتبع
      final token = await _firebaseMessaging!.getToken();
      print('✅ FCM Token: ${token ?? "null"}');
    } catch (e) {
      print('⚠️ خطأ في طلب الأذونات: $e');
    }
  }

  // معالجة الإشعارات عندما يكون التطبيق مفتوحاً
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📬 استلام إشعار: ${message.notification?.title}');

    // ✅ عرض الإشعار (الصوت والاهتزاز يأتيان من القناة تلقائياً)
    await _showLocalNotification(message);
  }

  // عرض إشعار محلي
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'school_notifications_v2', // ✅ يطابق القناة الجديدة
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

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'إشعار جديد',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  // عند الضغط على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 تم الضغط على الإشعار: ${response.payload}');
    // يمكن إضافة navigation هنا
  }

  // عند فتح التطبيق من الإشعار
  void _handleNotificationOpen(RemoteMessage message) {
    print('📱 فتح التطبيق من الإشعار: ${message.notification?.title}');
    // يمكن إضافة navigation هنا
  }

  // الحصول على FCM Token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging?.getToken();
    } catch (e) {
      print('⚠️ خطأ في جلب FCM Token: $e');
      return null;
    }
  }

  // الاشتراك في topic معين
  Future<void> subscribeToTopic(String topic) async {
    if (_firebaseMessaging == null) {
      print('⚠️ Firebase Messaging غير متوفر');
      return;
    }
    
    try {
      await _firebaseMessaging!.subscribeToTopic(topic);
      print('✅ تم الاشتراك في: $topic');
    } catch (e) {
      print('❌ خطأ في الاشتراك: $e');
    }
  }

  // إلغاء الاشتراك من topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_firebaseMessaging == null) {
      print('⚠️ Firebase Messaging غير متوفر');
      return;
    }
    
    try {
      await _firebaseMessaging!.unsubscribeFromTopic(topic);
      print('✅ تم إلغاء الاشتراك من: $topic');
    } catch (e) {
      print('❌ خطأ في إلغاء الاشتراك: $e');
    }
  }
}

// ✅ Topics Extension (من المشروع القديم)
extension NotificationTopics on NotificationService {
  Future<void> subscribeForUser(Map<String, dynamic> data) async {
    try {
      // إلغاء الاشتراك من الموضوع العام
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic('all-users');
      } catch (_) {}

      final role = (data['role'] ?? '').toString();
      final grade = (data['grade'] ?? '').toString();
      final section = (data['section'] ?? '').toString();

      // الاشتراك حسب الدور
      if (role == 'student') {
        await FirebaseMessaging.instance.subscribeToTopic('students');
        print('✅ اشتراك في: students');
        
        if (grade.isNotEmpty && section.isNotEmpty) {
          // ✅ تحويل الأحرف العربية إلى ASCII
          final gradeEncoded = Uri.encodeComponent(grade);
          final sectionEncoded = Uri.encodeComponent(section);
          final topic = 'g_${gradeEncoded}_s_$sectionEncoded';
          
          await FirebaseMessaging.instance.subscribeToTopic(topic);
          print('✅ اشتراك في: $topic (الصف: $grade، الشعبة: $section)');
        }
        
        final uid = (data['uid'] ?? '').toString();
        if (uid.isNotEmpty) {
          await FirebaseMessaging.instance.subscribeToTopic('student_$uid');
          print('✅ اشتراك في: student_$uid');
        }
      } else if (role == 'teacher') {
        await FirebaseMessaging.instance.subscribeToTopic('teachers');
        print('✅ اشتراك في: teachers');
      } else if (role == 'admin') {
        await FirebaseMessaging.instance.subscribeToTopic('admins');
        print('✅ اشتراك في: admins');
      }
      
      print('✅ تم الاشتراك في Topics بنجاح');
    } catch (e) {
      print('⚠️ خطأ في الاشتراك في Topics: $e');
    }
  }
}
