import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

/// شاشة إرسال تنبيه إداري عام
class SendAdminAnnouncementScreen extends StatefulWidget {
  const SendAdminAnnouncementScreen({super.key});

  @override
  State<SendAdminAnnouncementScreen> createState() => _SendAdminAnnouncementScreenState();
}

class _SendAdminAnnouncementScreenState extends State<SendAdminAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetRole = 'all';
  String _announcementType = 'info';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _targetRoles = [
    {'value': 'all', 'label': 'الجميع (طلاب ومعلمون)', 'icon': Icons.groups},
    {'value': 'student', 'label': 'الطلاب فقط', 'icon': Icons.school},
    {'value': 'teacher', 'label': 'المعلمون فقط', 'icon': Icons.person},
  ];

  final List<Map<String, dynamic>> _announcementTypes = [
    {'value': 'info', 'label': 'معلومة', 'icon': Icons.info, 'color': Colors.blue},
    {'value': 'success', 'label': 'نجاح', 'icon': Icons.check_circle, 'color': Colors.green},
    {'value': 'warning', 'label': 'تحذير', 'icon': Icons.warning, 'color': Colors.orange},
    {'value': 'error', 'label': 'خطأ', 'icon': Icons.error, 'color': Colors.red},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm').format(now);

      // إنشاء التنبيه في Firestore
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'targetRole': _targetRole,
        'type': _announcementType,
        'date': dateStr,
        'time': timeStr,
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 365))), // يبقى لمدة عام
        'bannerExpiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))), // البانر 24 ساعة
        'isActive': true,
      });

      // Cloud Function ستتولى إرسال الإشعارات تلقائياً
      // (راجع functions/index.js - notifyOnAnnouncement)

      if (!mounted) return;

      _titleController.clear();
      _messageController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التنبيه الإداري بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان
            const Text(
              'إرسال تنبيه إداري',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم إرسال الإشعار للمستخدمين المحددين',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // نوع التنبيه
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع التنبيه',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _announcementTypes.map((type) {
                        final isSelected = _announcementType == type['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'],
                                size: 18,
                                color: isSelected ? Colors.white : type['color'],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type['label'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: type['color'],
                          onSelected: (selected) {
                            setState(() {
                              _announcementType = type['value'];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // الفئة المستهدفة
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الفئة المستهدفة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._targetRoles.map((role) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(role['icon'], size: 20),
                            const SizedBox(width: 8),
                            Text(role['label']),
                          ],
                        ),
                        value: role['value'],
                        groupValue: _targetRole,
                        onChanged: (value) {
                          setState(() {
                            _targetRole = value!;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // عنوان التنبيه
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'محتوى التنبيه',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان التنبيه',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال عنوان التنبيه';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'نص التنبيه',
                        prefixIcon: const Icon(Icons.message),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال نص التنبيه';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملاحظة:',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• سيظهر التنبيه في بانر لمدة 24 ساعة\n'
                          '• سيُحفظ في تبويب التنبيهات للأرشيف\n'
                          '• سيتم إرسال إشعار push للمستخدمين',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // زر الإرسال
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendAnnouncement,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text(
                'إرسال التنبيه',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
