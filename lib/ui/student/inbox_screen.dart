import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  
  Future<List<Map<String, dynamic>>> _loadAllNotifications(String? uid, DateTime now) async {
    if (uid == null) {
      print('❌ UID is null');
      return [];
    }
    
    print('🔍 تحميل الإشعارات لـ UID: $uid');
    
    final List<Map<String, dynamic>> allNotifications = [];
    
    try {
      // الحصول على دور المستخدم
      final userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();
      
      final userRole = userDoc.exists ? 'student' : 'teacher';
      print('👤 دور المستخدم: $userRole');
      
      // 1. تحميل إشعارات الإدارة من announcements (لمدة سنة)
      try {
        print('📢 تحميل إشعارات الإدارة...');
        
        // تحميل جميع الإشعارات النشطة
        final announcementsQuery = await FirebaseFirestore.instance
            .collection('announcements')
            .where('isActive', isEqualTo: true)
            .get();
        
        print('📢 عدد إشعارات الإدارة الكلي: ${announcementsQuery.docs.length}');
        
        for (var doc in announcementsQuery.docs) {
          final data = doc.data();
          final targetRole = data['targetRole'] as String?;
          final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
          
          // فلترة حسب التاريخ والدور
          if (expiresAt != null && expiresAt.isAfter(now)) {
            print('   - إشعار: ${data['title']}, مستهدف: $targetRole');
            
            // فلترة حسب الدور المستهدف
            if (targetRole == 'all' || targetRole == userRole) {
              allNotifications.add({
                'title': data['title'] ?? 'إشعار إداري',
                'body': data['message'] ?? '',
                'type': data['type'] ?? 'info',
                'createdAt': data['timestamp'],
                'read': false,
                'source': 'announcement',
                'id': doc.id,
              });
              print('   ✅ تمت الإضافة');
            } else {
              print('   ❌ تم التجاهل (دور غير مطابق)');
            }
          } else {
            print('   ⏰ تم التجاهل (منتهي الصلاحية)');
          }
        }
      } catch (e) {
        print('❌ خطأ في تحميل إشعارات الإدارة: $e');
      }
      
      // 2. تحميل إشعارات مباشرة (notifications)
      final directNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      for (var doc in directNotifications.docs) {
        final data = doc.data();
        allNotifications.add({
          ...data,
          'source': 'notification',
          'id': doc.id,
        });
      }
      
      // 3. تحميل إشعارات الغياب (لمدة سنة)
      try {
        print('⚠️ تحميل إشعارات الغياب...');
        final absenceNotifications = await FirebaseFirestore.instance
            .collection('notifications_absences')
            .where('studentUid', isEqualTo: uid)
            .where('archiveUntil', isGreaterThan: Timestamp.fromDate(now))
            .orderBy('archiveUntil', descending: true)
            .get();
        
        print('⚠️ عدد إشعارات الغياب: ${absenceNotifications.docs.length}');
        
        for (var doc in absenceNotifications.docs) {
          final data = doc.data();
          print('   - غياب: ${data['message']}');
          allNotifications.add({
            'title': 'إشعار غياب',
            'body': data['message'] ?? '',
            'type': 'absence',
            'createdAt': data['createdAt'],
            'date': data['date'],
            'read': data['read'] ?? false,
            'source': 'absence',
            'id': doc.id,
          });
          print('   ✅ تمت الإضافة');
        }
      } catch (e) {
        print('❌ خطأ في تحميل إشعارات الغياب: $e');
      }
      
      // ترتيب حسب التاريخ
      allNotifications.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      
      print('✅ إجمالي الإشعارات المحملة: ${allNotifications.length}');
      
    } catch (e) {
      print('❌ خطأ في تحميل الإشعارات: $e');
    }
    
    return allNotifications;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التنبيهات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadAllNotifications(user?.uid, now),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.iconSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'لا توجد إشعارات',
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

            final notifications = snapshot.data!;
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data = notifications[index];
                
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
                        color: _getNotificationColor(data['type']).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNotificationIcon(data['type']),
                        color: _getNotificationColor(data['type']),
                      ),
                    ),
                    title: Text(
                      data['title'] ?? 'إشعار',
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
                          data['body'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(data['createdAt']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: !data['read']
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.buttonPrimary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      // يمكن إضافة تفاصيل هنا
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'homework':
        return Icons.assignment;
      case 'absence':
        return Icons.warning_amber_rounded;
      case 'announcement':
        return Icons.campaign;
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'homework':
        return Colors.blue;
      case 'absence':
        return Colors.red;
      case 'announcement':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return AppColors.buttonPrimary;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'الآن';
    
    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'الآن';
      } else if (difference.inHours < 1) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inDays < 1) {
        return 'منذ ${difference.inHours} ساعة';
      } else {
        return 'منذ ${difference.inDays} يوم';
      }
    } catch (e) {
      return '';
    }
  }
}
