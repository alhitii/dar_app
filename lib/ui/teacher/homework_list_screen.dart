import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/homework_model.dart';
import '../../utils/date_formatter.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';

class HomeworkListScreen extends StatelessWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الواجبات المرسلة'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('homework')
            .where('teacherId', isEqualTo: currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'جاري تحميل الواجبات...');
          }

          final homeworks = snapshot.data!.docs;

          if (homeworks.isEmpty) {
            return const EmptyStateWidget(
              message: 'لم يتم إرسال أي واجبات بعد',
              icon: Icons.assignment,
            );
          }

          return ListView.builder(
            itemCount: homeworks.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final homework = HomeworkModel.fromMap(
                homeworks[index].id,
                homeworks[index].data() as Map<String, dynamic>,
              );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(homework.subjectName[0]),
                  ),
                  title: Text(
                    homework.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(homework.subjectName),
                      Text(
                        'الموعد النهائي: ${DateFormatter.formatDate(homework.dueDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${homework.stage} - ${homework.grade} - ${homework.section}',
                        style: const TextStyle(fontSize: 12),
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
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('homework')
                            .doc(homework.id)
                            .delete();
                        
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
      ),
    );
  }
}
