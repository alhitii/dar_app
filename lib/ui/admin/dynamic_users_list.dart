import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_management_service.dart';
import 'create_teacher_screen.dart';
import 'edit_teacher_dialog.dart';

class DynamicTeachersList extends StatefulWidget {
  const DynamicTeachersList({super.key});

  @override
  State<DynamicTeachersList> createState() => _DynamicTeachersListState();
}

class _DynamicTeachersListState extends State<DynamicTeachersList> {
  final UserManagementService _userService = UserManagementService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteTeacher(String uid, String email, String name) async {
    // تأكيد الحذف
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المعلم: $name؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // استدعاء Cloud Function للحذف
      final result = await _userService.deleteUserCompletely(
        uid: uid,
        role: 'teacher',
        email: email,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // نجح الحذف الكامل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'تم حذف المعلم نهائياً من جميع الأماكن'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // فشل الحذف
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل حذف المعلم'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
    return Column(
      children: [
        // زر الإضافة وشريط البحث
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // زر إضافة معلم
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTeacherScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة معلم جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90A4),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 12),
              // شريط البحث
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو البريد الإلكتروني...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // قائمة المعلمين
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teachers')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allTeachers = snapshot.data!.docs;
              
              // تطبيق البحث والترتيب
              final teachers = allTeachers.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final email = (data['email'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) || email.contains(_searchQuery);
              }).toList()
                ..sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aName = (aData['name'] ?? '').toString();
                  final bName = (bData['name'] ?? '').toString();
                  return aName.compareTo(bName);
                });

              if (teachers.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'لا يوجد معلمون مسجلون\nانقر على "إضافة معلم جديد" للبدء'
                        : 'لا توجد نتائج للبحث',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  final teacher = teachers[index];
                  final data = teacher.data() as Map<String, dynamic>;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        data['name'] ?? 'بدون اسم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['email'] ?? ''),
                          if (data['stage'] != null || data['grade'] != null)
                            Text(
                              '${data['stage'] ?? ''} ${data['grade'] ?? ''}${data['branch'] != null && data['branch'].toString().isNotEmpty ? ' - ${data['branch']}' : ''}'.trim(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // زر التعديل
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => EditTeacherDialog(
                                  teacherId: teacher.id,
                                  teacherData: data,
                                ),
                              );
                              if (result == true) {
                                // تم التحديث بنجاح
                              }
                            },
                          ),
                          // زر الحذف
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTeacher(
                              teacher.id,
                              data['email'] ?? '',
                              data['name'] ?? 'بدون اسم',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
