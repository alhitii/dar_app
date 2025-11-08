import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../utils/app_colors.dart';
import '../../utils/education_system.dart';
import '../../firebase_options.dart';

/// شاشة إنشاء حساب طالب جديد - نظام محدّث
class CreateStudentScreenNew extends StatefulWidget {
  const CreateStudentScreenNew({super.key});

  @override
  State<CreateStudentScreenNew> createState() => _CreateStudentScreenNewState();
}

class _CreateStudentScreenNewState extends State<CreateStudentScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // المرحلة الدراسية
  EducationLevel? _selectedLevel;
  
  // الصف الدراسي
  String? _selectedGrade;
  
  // الفرع (للإعدادية فقط)
  String? _selectedBranch;
  
  // الشعبة
  String _selectedSection = 'أ';
  
  bool _isLoading = false;
  String _generatedEmail = '';
  List<String> _availableSubjects = [];

  final List<String> _sections = ['أ', 'ب', 'ج', 'د'];

  @override
  void initState() {
    super.initState();
    // تحديث البريد الإلكتروني تلقائياً
    _usernameController.addListener(() {
      setState(() {
        _generatedEmail = _usernameController.text.trim().isEmpty
            ? ''
            : '${_usernameController.text.trim()}@codeira.com';
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // تحديث المواد عند تغيير المرحلة/الصف/الفرع
  void _updateSubjects() {
    if (_selectedLevel == null || _selectedGrade == null) {
      setState(() {
        _availableSubjects = [];
      });
      return;
    }

    // للإعدادية، نحتاج الفرع
    if (_selectedLevel == EducationLevel.secondary && _selectedBranch == null) {
      setState(() {
        _availableSubjects = [];
      });
      return;
    }

    setState(() {
      _availableSubjects = EducationSystem.getSubjectsForGrade(
        _selectedGrade!,
        branch: _selectedBranch,
      );
    });
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من اختيار المرحلة والصف
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المرحلة الدراسية'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الصف الدراسي'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // للإعدادية، التحقق من الفرع
    if (_selectedLevel == EducationLevel.secondary && _selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الفرع الدراسي'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FirebaseApp? secondaryApp;
    try {
      // البريد الإلكتروني الكامل
      final fullEmail = '${_usernameController.text.trim()}@codeira.com';

      // ✅ إنشاء Firebase App ثانوي لإنشاء حساب بدون تسجيل خروج الإدارة
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // إنشاء الحساب باستخدام Auth الثانوي
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: fullEmail,
        password: _passwordController.text,
      );

      // إضافة بيانات الطالب في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': fullEmail,
        'role': 'student',
        'level': _selectedLevel!.name,
        'grade': _selectedGrade,
        'branch': _selectedBranch,
        'section': _selectedSection,
        'subjects': _availableSubjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء حساب الطالب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء إنشاء الحساب';
      if (e.code == 'email-already-in-use') {
        message = 'اسم المستخدم مستخدم بالفعل';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
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
      // ✅ حذف التطبيق الثانوي بعد الانتهاء
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.person_add,
                      color: AppColors.buttonPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إنشاء حساب طالب جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // اسم الطالب
                        _buildTextField(
                          controller: _nameController,
                          label: 'اسم الطالب',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال اسم الطالب';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // اسم المستخدم
                        _buildTextField(
                          controller: _usernameController,
                          label: 'اسم المستخدم (Username)',
                          hint: 'مثال: sara2024',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال اسم المستخدم';
                            }
                            if (value.contains('@') || value.contains(' ')) {
                              return 'اسم المستخدم يجب أن يكون بدون @ أو مسافات';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // عرض البريد المولد
                        if (_generatedEmail.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.email, color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'البريد الإلكتروني:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _generatedEmail,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // كلمة المرور
                        _buildTextField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // المرحلة الدراسية
                        _buildLevelSelector(),
                        const SizedBox(height: 16),
                        
                        // الصف الدراسي
                        if (_selectedLevel != null) _buildGradeSelector(),
                        if (_selectedLevel != null) const SizedBox(height: 16),
                        
                        // الفرع (للإعدادية فقط)
                        if (_selectedLevel == EducationLevel.secondary && _selectedGrade != null)
                          _buildBranchSelector(),
                        if (_selectedLevel == EducationLevel.secondary && _selectedGrade != null)
                          const SizedBox(height: 16),
                        
                        // الشعبة
                        if (_selectedGrade != null) _buildSectionSelector(),
                        if (_selectedGrade != null) const SizedBox(height: 24),
                        
                        // عرض المواد
                        if (_availableSubjects.isNotEmpty) _buildSubjectsDisplay(),
                        if (_availableSubjects.isNotEmpty) const SizedBox(height: 24),
                        
                        // زر الإنشاء
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'إنشاء الحساب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildLevelSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: AppColors.buttonPrimary),
                SizedBox(width: 8),
                Text(
                  'المرحلة الدراسية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...EducationLevel.values.map((level) {
              return RadioListTile<EducationLevel>(
                title: Text(EducationSystem.getLevelName(level)),
                value: level,
                groupValue: _selectedLevel,
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value;
                    _selectedGrade = null;
                    _selectedBranch = null;
                    _availableSubjects = [];
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeSelector() {
    final grades = EducationSystem.getGradesForLevel(_selectedLevel!);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.class_, color: AppColors.buttonPrimary),
                SizedBox(width: 8),
                Text(
                  'الصف الدراسي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...grades.map((grade) {
              return RadioListTile<String>(
                title: Text(grade),
                value: grade,
                groupValue: _selectedGrade,
                onChanged: (value) {
                  setState(() {
                    _selectedGrade = value;
                    _selectedBranch = null;
                    _updateSubjects();
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_tree, color: AppColors.buttonPrimary),
                SizedBox(width: 8),
                Text(
                  'الفرع الدراسي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...['علمي', 'أدبي'].map((branch) {
              return RadioListTile<String>(
                title: Text(branch),
                value: branch,
                groupValue: _selectedBranch,
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
                    _updateSubjects();
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedSection,
      decoration: InputDecoration(
        labelText: 'الشعبة',
        prefixIcon: const Icon(Icons.group),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _sections.map((section) {
        return DropdownMenuItem(
          value: section,
          child: Text(section),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSection = value!;
        });
      },
    );
  }

  Widget _buildSubjectsDisplay() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.book, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'المواد الدراسية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSubjects.map((subject) {
                return Chip(
                  label: Text(subject),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
