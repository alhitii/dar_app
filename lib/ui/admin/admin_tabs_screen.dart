import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/school_theme.dart';
import '../../utils/pink_theme.dart';
import 'dynamic_users_list.dart';
import 'students_management_screen.dart';
import 'admins_management_screen.dart';
import 'send_admin_announcement_screen.dart';

class AdminTabsScreen extends StatelessWidget {
  const AdminTabsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حساب الإدارة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // تسجيل الخروج من Firebase
      await FirebaseAuth.instance.signOut();
      
      // مسح حفظ تسجيل الدخول
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rememberMe');
      await prefs.remove('userEmail');

      if (!context.mounted) return;

      Navigator.pushReplacementNamed(context, '/login_new');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: PinkTheme.mainGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header مع الشعار
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: SchoolTheme.elevatedCardDecoration,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: PinkTheme.buttonGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: PinkTheme.pink2.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'لوحة تحكم الإدارة',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ثانوية دار السلام للبنات',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.logout_rounded, color: Colors.red.shade600),
                              onPressed: () => _logout(context),
                              tooltip: 'تسجيل الخروج',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // التبويبات
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            gradient: PinkTheme.buttonGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF7F8C8D),
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.people_rounded, size: 22),
                              text: 'الطلاب',
                              height: 56,
                            ),
                            Tab(
                              icon: Icon(Icons.school_rounded, size: 22),
                              text: 'المعلمون',
                              height: 56,
                            ),
                            Tab(
                              icon: Icon(Icons.admin_panel_settings_rounded, size: 22),
                              text: 'الإدارة',
                              height: 56,
                            ),
                            Tab(
                              icon: Icon(Icons.notifications_active_rounded, size: 22),
                              text: 'تنبيه إداري',
                              height: 56,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // المحتوى
                Expanded(
                  child: TabBarView(
                    children: const [
                      StudentsManagementScreen(),
                      DynamicTeachersList(),
                      AdminsManagementScreen(),
                      SendAdminAnnouncementScreen(),
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
}
