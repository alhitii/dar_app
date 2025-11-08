import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/education_constants.dart';

/// نافذة تعديل بيانات الطالب - مطابقة لنافذة الإنشاء
class EditStudentDialog extends StatefulWidget {
  final String studentUid;
  final String currentName;
  final String currentEmail;
  final String currentStage;
  final String currentGrade;
  final String? currentBranch;
  final String currentSection;

  const EditStudentDialog({
    super.key,
    required this.studentUid,
    required this.currentName,
    required this.currentEmail,
    required this.currentStage,
    required this.currentGrade,
    this.currentBranch,
    required this.currentSection,
  });

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedStage;
  late String _selectedGrade;
  String? _selectedBranch;
  late String _selectedSection;
  List<Map<String, dynamic>> _availableSubjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedStage = widget.currentStage;
    _selectedGrade = widget.currentGrade;
    _selectedBranch = widget.currentBranch;
    _selectedSection = widget.currentSection;
    _loadAvailableSubjects();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// تحميل المواد ديناميكياً حسب المرحلة والصف والفرع
  Future<void> _loadAvailableSubjects() async {
    if (_selectedStage.isEmpty || _selectedGrade.isEmpty) {
      setState(() => _availableSubjects = []);
      return;
    }

    if (_selectedStage == 'إعدادية' && _selectedBranch == null) {
      setState(() => _availableSubjects = []);
      return;
    }

    try {
      Query query = FirebaseFirestore.instance.collection('subjects');
      
      query = query.where('stage', isEqualTo: _selectedStage);
      query = query.where('grade', isEqualTo: _selectedGrade);
      
      if (_selectedStage == 'إعدادية' && _selectedBranch != null) {
        query = query.where('branch', isEqualTo: _selectedBranch);
      }

      final snapshot = await query.get();
      
      setState(() {
        _availableSubjects = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name': data['name'] ?? '',
                'emoji': data['emoji'] ?? '',
              };
            })
            .toList();
        
        _availableSubjects.sort((a, b) => a['name'].compareTo(b['name']));
      });
    } catch (e) {
      print('خطأ في تحميل المواد: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // إعداد بيانات الطالب المحدثة
      final studentData = {
        'name': _nameController.text.trim(),
        'stage': _selectedStage,
        'grade': _selectedGrade,
        'section': _selectedSection,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // إضافة الفرع إذا كانت إعدادية
      if (_selectedStage == 'إعدادية' && _selectedBranch != null) {
        studentData['branch'] = _selectedBranch!;
      }

      // تحديث في users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentUid)
          .update(studentData);

      // تحديث في students collection أيضاً
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentUid)
          .update(studentData);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث بيانات الطالب بنجاح'),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // العنوان
                Row(
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'تعديل بيانات الطالب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // الاسم
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطالب',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الطالب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // البريد الإلكتروني (للعرض فقط)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'البريد: ${widget.currentEmail}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // المرحلة
                DropdownButtonFormField<String>(
                  value: _selectedStage,
                  decoration: const InputDecoration(
                    labelText: 'المرحلة',
                    border: OutlineInputBorder(),
                  ),
                  items: EducationConstants.stages.map((stage) {
                    return DropdownMenuItem(value: stage, child: Text(stage));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStage = value!;
                      _selectedGrade = (EducationConstants.gradesByStage[_selectedStage] ?? []).first;
                      _selectedBranch = null;
                      _availableSubjects = [];
                    });
                    _loadAvailableSubjects();
                  },
                  validator: (value) => value == null ? 'الرجاء اختيار المرحلة' : null,
                ),
                const SizedBox(height: 16),

                // الصف
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'الصف',
                    border: OutlineInputBorder(),
                  ),
                  items: (EducationConstants.gradesByStage[_selectedStage] ?? [])
                      .map((grade) {
                    return DropdownMenuItem(value: grade, child: Text(grade));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value!;
                      _selectedBranch = null;
                      _availableSubjects = [];
                    });
                    _loadAvailableSubjects();
                  },
                  validator: (value) => value == null ? 'الرجاء اختيار الصف' : null,
                ),
                const SizedBox(height: 16),

                // الفرع (للإعدادية فقط)
                if (_selectedStage == 'إعدادية')
                  DropdownButtonFormField<String>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(
                      labelText: 'الفرع',
                      border: OutlineInputBorder(),
                    ),
                    items: EducationConstants.branches.map((branch) {
                      return DropdownMenuItem(value: branch, child: Text(branch));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBranch = value;
                      });
                      _loadAvailableSubjects();
                    },
                    validator: (value) => value == null ? 'الرجاء اختيار الفرع' : null,
                  ),
                if (_selectedStage == 'إعدادية')
                  const SizedBox(height: 16),

                // الشعبة
                DropdownButtonFormField<String>(
                  value: _selectedSection,
                  decoration: const InputDecoration(
                    labelText: 'الشعبة',
                    border: OutlineInputBorder(),
                  ),
                  items: ['أ', 'ب', 'ج', 'د'].map((section) {
                    return DropdownMenuItem(value: section, child: Text(section));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSection = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // عرض المواد
                if (_availableSubjects.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade100.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'المواد الدراسية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_availableSubjects.length} مادة',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.green, thickness: 1),
                        const SizedBox(height: 16),
                        // المواد
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: _availableSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _availableSubjects[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // الإيموجي
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      subject['emoji'] ?? '📚',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // اسم المادة
                                  Expanded(
                                    child: Text(
                                      subject['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                if (_availableSubjects.isNotEmpty) const SizedBox(height: 24),

                // أزرار الحفظ والإلغاء
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'حفظ التغييرات',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
