import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../constants/education_constants.dart';
import '../../firebase_options.dart';

/// شاشة إنشاء حساب طالب - نسخة بسيطة مثل المعلم
class CreateStudentScreenSimple extends StatefulWidget {
  const CreateStudentScreenSimple({super.key});

  @override
  State<CreateStudentScreenSimple> createState() => _CreateStudentScreenSimpleState();
}

class _CreateStudentScreenSimpleState extends State<CreateStudentScreenSimple> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedStage;
  String? _selectedGrade;
  String? _selectedBranch;
  String _selectedSection = 'أ';
  List<Map<String, dynamic>> _availableSubjects = [];
  
  bool _isLoading = false;
  String _generatedEmail = '';

  @override
  void initState() {
    super.initState();
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// تحميل المواد ديناميكياً حسب المرحلة والصف والفرع
  Future<void> _loadAvailableSubjects() async {
    if (_selectedStage == null || _selectedGrade == null) {
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

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    if (_selectedStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المرحلة')),
      );
      return;
    }

    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الصف')),
      );
      return;
    }

    if (_selectedStage == 'إعدادية' && _selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفرع')),
      );
      return;
    }

    setState(() => _isLoading = true);

    FirebaseApp? secondaryApp;
    try {
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

      // إعداد بيانات الطالب
      final studentData = {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': fullEmail,
        'role': 'student',
        'stage': _selectedStage,
        'grade': _selectedGrade,
        'section': _selectedSection,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // إضافة الفرع إذا كانت إعدادية
      if (_selectedStage == 'إعدادية' && _selectedBranch != null) {
        studentData['branch'] = _selectedBranch;
      }

      // حفظ في Firestore - في كلا المكانين
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(studentData);
      
      // حفظ أيضاً في students collection
      await FirebaseFirestore.instance
          .collection('students')
          .doc(userCredential.user!.uid)
          .set(studentData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء حساب الطالب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء إنشاء الحساب';
      if (e.code == 'email-already-in-use') {
        message = 'اسم المستخدم مستخدم بالفعل';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      // ✅ حذف التطبيق الثانوي بعد الانتهاء
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب طالب جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              // اسم المستخدم
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم (Username)',
                  hintText: 'مثال: ali2024',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المستخدم';
                  }
                  if (value.contains('@') || value.contains(' ')) {
                    return 'اسم المستخدم يجب أن يكون بدون @ أو مسافات';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // عرض البريد المولد
              if (_generatedEmail.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'البريد: $_generatedEmail',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // كلمة المرور
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
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
              const SizedBox(height: 16),

              // تأكيد كلمة المرور
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء تأكيد كلمة المرور';
                  }
                  if (value != _passwordController.text) {
                    return 'كلمتا المرور غير متطابقتين';
                  }
                  return null;
                },
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
                    _selectedStage = value;
                    _selectedGrade = null;
                    _selectedBranch = null;
                    _availableSubjects = [];
                  });
                },
                validator: (value) => value == null ? 'الرجاء اختيار المرحلة' : null,
              ),
              const SizedBox(height: 16),

              // الصف
              if (_selectedStage != null)
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
                      _selectedGrade = value;
                      _selectedBranch = null;
                      _availableSubjects = [];
                    });
                    _loadAvailableSubjects();
                  },
                  validator: (value) => value == null ? 'الرجاء اختيار الصف' : null,
                ),
              if (_selectedStage != null) const SizedBox(height: 16),

              // الفرع (للإعدادية فقط)
              if (_selectedStage == 'إعدادية' && _selectedGrade != null)
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
              if (_selectedStage == 'إعدادية' && _selectedGrade != null)
                const SizedBox(height: 16),

              // الشعبة
              if (_selectedGrade != null)
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
              if (_selectedGrade != null) const SizedBox(height: 16),

              // عرض المواد
              if (_availableSubjects.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
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
                            label: Text('${subject['emoji']} ${subject['name']}'),
                            backgroundColor: Colors.green.shade50,
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
              if (_availableSubjects.isNotEmpty) const SizedBox(height: 24),

              // زر الإنشاء
              ElevatedButton(
                onPressed: _isLoading ? null : _createStudent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
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
                        'إنشاء الحساب',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
