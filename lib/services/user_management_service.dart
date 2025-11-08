import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

/// خدمة إدارة المستخدمين (حذف، تحديث، إلخ)
class UserManagementService {
  late final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserManagementService() {
    // إذا كنا على Windows Desktop، استخدم المنطقة الصحيحة
    if (!kIsWeb && Platform.isWindows) {
      _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      // تفعيل الاتصال المباشر بـ Cloud Functions (بدون emulator)
      // لا حاجة لـ useEmulator على production
    } else {
      _functions = FirebaseFunctions.instance;
    }
    
    print('✅ تم تهيئة FirebaseFunctions للمنطقة: us-central1');
  }

  /// حذف مستخدم بالكامل من Authentication و Firestore
  /// 
  /// يستدعي Cloud Function المنشورة
  /// 
  /// Parameters:
  ///   - uid: معرف المستخدم
  ///   - role: الدور (teacher, student, admin)
  ///   - email: البريد الإلكتروني
  /// 
  /// Returns:
  ///   - Map يحتوي على success, message, warning (إن وجد)
  Future<Map<String, dynamic>> deleteUserCompletely({
    required String uid,
    required String role,
    required String email,
  }) async {
    try {
      print('🗑️ محاولة حذف المستخدم عبر Cloud Function: $email ($role)');
      
      // محاولة استخدام HTTP Request مباشرة (أفضل لـ Windows)
      try {
        print('📞 استدعاء Cloud Function عبر HTTP...');
        
        // الحصول على ID Token
        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken();
        
        final url = Uri.parse('https://us-central1-madrasa-570c9.cloudfunctions.net/deleteUserCompletely');
        
        print('📤 إرسال البيانات: uid=$uid, role=$role, email=$email');
        
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'data': {
              'uid': uid,
              'role': role,
              'email': email,
            }
          }),
        ).timeout(const Duration(seconds: 30));

        print('📥 استجابة HTTP: ${response.statusCode}');
        print('📥 Body: ${response.body}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('✅ نجح الحذف عبر Cloud Function');
          
          return {
            'success': data['result']?['success'] ?? true,
            'message': data['result']?['message'] ?? 'تم حذف المستخدم بنجاح من Authentication و Firestore',
          };
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        print('❌ خطأ في HTTP Request: $e');
        print('⚠️ استخدام الحذف المباشر من Firestore فقط');
        
        // Fallback: حذف مباشر من Firestore
        await _firestore.collection('users').doc(uid).delete();
        print('✅ تم حذف من users');
        
        if (role == 'student') {
          await _firestore.collection('students').doc(uid).delete();
          print('✅ تم حذف من students');
        } else if (role == 'teacher') {
          await _firestore.collection('teachers').doc(uid).delete();
          print('✅ تم حذف من teachers');
        } else if (role == 'admin') {
          await _firestore.collection('admins').doc(uid).delete();
          print('✅ تم حذف من admins');
        }
        
        return {
          'success': true,
          'message': 'تم حذف المستخدم من قاعدة البيانات بنجاح\n\n⚠️ ملاحظة: HTTP Request فشل\nيجب حذف الحساب من Firebase Authentication يدوياً:\n1. افتح Firebase Console\n2. Authentication > Users\n3. احذف: $email',
        };
      }
    } catch (e) {
      print('❌ خطأ في الحذف: $e');
      return {
        'success': false,
        'message': 'فشل الحذف: ${e.toString()}',
      };
    }
  }
}
