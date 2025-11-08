import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/teacher_setup_service.dart';
import '../../constants/education_constants.dart';
import '../../utils/pink_theme.dart';

class CreateTeacherScreen extends StatefulWidget {
  const CreateTeacherScreen({super.key});

  @override
  State<CreateTeacherScreen> createState() => _CreateTeacherScreenState();
}

class _CreateTeacherScreenState extends State<CreateTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _generatedEmail = '';
  
  final TeacherSetupService _teacherService = TeacherSetupService();
  
  List<String> _selectedStages = [];
  List<String> _selectedGrades = [];
  List<String> _selectedBranches = [];
  List<String> _selectedSections = [];
  List<String> _selectedSubjects = [];
  
  bool _isLoading = false;

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


  Future<void> _createTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار مرحلة واحدة على الأقل')),
      );
      return;
    }

    if (_selectedGrades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صف واحد على الأقل')),
      );
      return;
    }

    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار شعبة واحدة على الأقل')),
      );
      return;
    }

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار مادة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    try {
      final fullEmail = '${_usernameController.text.trim()}@codeira.com';
      
      final result = await _teacherService.createTeacherMulti(
        email: fullEmail,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        stages: _selectedStages,
        grades: _selectedGrades,
        branches: _selectedBranches,
        sections: _selectedSections,
        subjects: _selectedSubjects,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إنشاء حساب معلم جديد',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: PinkTheme.mainGradient,
          ),
        ),
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
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
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
                  hintText: 'مثال: ahmed2024',
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
              const SizedBox(height: 24),

              // المراحل
              _buildMultiSelectSection(
                title: 'المراحل:',
                items: EducationConstants.stages,
                selectedItems: _selectedStages,
                onChanged: (selected) {
                  setState(() => _selectedStages = selected);
                },
              ),
              
              const SizedBox(height: 16),

              // الصفوف
              _buildMultiSelectSection(
                title: 'الصفوف:',
                items: ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'],
                selectedItems: _selectedGrades,
                onChanged: (selected) {
                  setState(() => _selectedGrades = selected);
                },
              ),
              
              const SizedBox(height: 16),

              // الفروع (للإعدادية)
              if (_selectedStages.contains('إعدادية'))
                Column(
                  children: [
                    _buildMultiSelectSection(
                      title: 'الفروع:',
                      items: EducationConstants.branches,
                      selectedItems: _selectedBranches,
                      onChanged: (selected) {
                        setState(() => _selectedBranches = selected);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // الشعب
              _buildMultiSelectSection(
                title: 'الشعب:',
                items: EducationConstants.sections,
                selectedItems: _selectedSections,
                onChanged: (selected) {
                  setState(() => _selectedSections = selected);
                },
              ),
              
              const SizedBox(height: 16),

              // المواد - عرض احترافي مجمع
              _buildGroupedSubjectsSection(),
              const SizedBox(height: 24),

              // زر الإنشاء
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTeacher,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إنشاء الحساب', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getAvailableSubjects() {
    if (_selectedStages.isEmpty || _selectedGrades.isEmpty) {
      return [];
    }

    final subjects = <Map<String, String>>[];

    // مواد الابتدائية
    if (_selectedStages.contains('ابتدائية')) {
      // المواد المشتركة لجميع صفوف الابتدائية
      subjects.addAll([
        {'name': 'التربية الإسلامية', 'emoji': '☪️'},
        {'name': 'اللغة العربية', 'emoji': '📖'},
        {'name': 'اللغة الإنكليزية', 'emoji': '🇬🇧'},
        {'name': 'الرياضيات', 'emoji': '📐'},
        {'name': 'العلوم', 'emoji': '🔬'},
        {'name': 'الرياضة', 'emoji': '⚽'},
        {'name': 'الفنية', 'emoji': '🎨'},
      ]);
      
      // التربية الأخلاقية (الأول والثاني فقط)
      final hasFirstOrSecond = _selectedGrades.isEmpty || 
                               _selectedGrades.contains('الأول') || 
                               _selectedGrades.contains('الثاني') ||
                               _selectedGrades.length >= 3;
      if (hasFirstOrSecond) {
        subjects.add({'name': 'التربية الأخلاقية', 'emoji': '💎'});
      }
      
      // الاجتماعيات (من الرابع فصاعداً)
      final hasFourthOrAbove = _selectedGrades.isEmpty || 
                               _selectedGrades.contains('الرابع') || 
                               _selectedGrades.contains('الخامس') ||
                               _selectedGrades.contains('السادس') ||
                               _selectedGrades.length >= 3;
      if (hasFourthOrAbove) {
        subjects.add({'name': 'الاجتماعيات', 'emoji': '🌍'});
      }
    }

    // مواد المتوسطة
    if (_selectedStages.contains('متوسطة')) {
      // المواد المشتركة لجميع صفوف المتوسطة
      subjects.addAll([
        {'name': 'التربية الإسلامية', 'emoji': '☪️'},
        {'name': 'اللغة العربية', 'emoji': '📖'},
        {'name': 'اللغة الإنكليزية', 'emoji': '🇬🇧'},
        {'name': 'الاجتماعيات', 'emoji': '🌍'},
        {'name': 'الرياضيات', 'emoji': '📐'},
        {'name': 'الفيزياء', 'emoji': '⚡'},
        {'name': 'الكيمياء', 'emoji': '🧪'},
        {'name': 'الأحياء', 'emoji': '🧬'},
        {'name': 'الحاسوب', 'emoji': '💻'},
        {'name': 'التربية الفنية', 'emoji': '🎨'},
        {'name': 'التربية الرياضية', 'emoji': '⚽'},
      ]);
      
      // التربية الأخلاقية (الأول والثاني فقط)
      final hasFirstOrSecond = _selectedGrades.isEmpty || 
                               _selectedGrades.contains('الأول') || 
                               _selectedGrades.contains('الثاني') ||
                               _selectedGrades.length >= 3;
      if (hasFirstOrSecond) {
        subjects.add({'name': 'التربية الأخلاقية', 'emoji': '💎'});
      }
    }

    // مواد الإعدادية
    if (_selectedStages.contains('إعدادية')) {
      // المواد المشتركة لجميع الفروع
      subjects.addAll([
        {'name': 'التربية الإسلامية', 'emoji': '☪️'},
        {'name': 'اللغة العربية', 'emoji': '📖'},
        {'name': 'اللغة الإنكليزية', 'emoji': '🇬🇧'},
        {'name': 'الرياضيات', 'emoji': '📐'},
        {'name': 'التربية الرياضية', 'emoji': '⚽'},
        {'name': 'التربية الفنية', 'emoji': '🎨'},
      ]);

      // مواد الفرع العلمي
      if (_selectedBranches.contains('علمي') || _selectedBranches.isEmpty) {
        subjects.addAll([
          {'name': 'الفيزياء', 'emoji': '⚡'},
          {'name': 'الكيمياء', 'emoji': '🧪'},
          {'name': 'الأحياء', 'emoji': '🧬'},
        ]);
        
        // جرائم حزب البعث (الرابع والخامس فقط - محذوفة من السادس)
        final hasFourthOrFifth = _selectedGrades.isEmpty || 
                                 _selectedGrades.contains('الرابع') || 
                                 _selectedGrades.contains('الخامس') ||
                                 _selectedGrades.length >= 3;
        if (hasFourthOrFifth) {
          subjects.add({'name': 'جرائم حزب البعث', 'emoji': '⚖️'});
        }
        
        // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
        if (hasFourthOrFifth) {
          subjects.add({'name': 'الحاسوب', 'emoji': '💻'});
        }
      }

      // مواد الفرع الأدبي
      if (_selectedBranches.contains('أدبي') || _selectedBranches.isEmpty) {
        subjects.addAll([
          {'name': 'التاريخ', 'emoji': '📜'},
          {'name': 'الجغرافية', 'emoji': '🗺️'},
        ]);
        
        // جرائم حزب البعث (الرابع فقط)
        final hasFourth = _selectedGrades.isEmpty || 
                         _selectedGrades.contains('الرابع') ||
                         _selectedGrades.length >= 3;
        if (hasFourth) {
          subjects.add({'name': 'جرائم حزب البعث', 'emoji': '⚖️'});
        }
        
        // الاجتماع (الرابع فقط)
        if (hasFourth) {
          subjects.add({'name': 'الاجتماع', 'emoji': '👥'});
        }
        
        // الاقتصاد (الخامس والسادس فقط)
        final hasFifthOrSixth = _selectedGrades.isEmpty || 
                                _selectedGrades.contains('الخامس') || 
                                _selectedGrades.contains('السادس') ||
                                _selectedGrades.length >= 3;
        if (hasFifthOrSixth) {
          subjects.add({'name': 'الاقتصاد', 'emoji': '💰'});
        }
        
        // الفلسفة وعلم النفس (الخامس فقط)
        final hasFifth = _selectedGrades.isEmpty || 
                        _selectedGrades.contains('الخامس') ||
                        _selectedGrades.length >= 3;
        if (hasFifth) {
          subjects.add({'name': 'الفلسفة وعلم النفس', 'emoji': '🤔'});
        }
        
        // الحاسوب (الرابع والخامس فقط - محذوف من السادس)
        final hasFourthOrFifthAdabi = _selectedGrades.isEmpty || 
                                      _selectedGrades.contains('الرابع') || 
                                      _selectedGrades.contains('الخامس') ||
                                      _selectedGrades.length >= 3;
        if (hasFourthOrFifthAdabi) {
          subjects.add({'name': 'الحاسوب', 'emoji': '💻'});
        }
      }
    }

    // إزالة التكرار
    final uniqueSubjects = <String, Map<String, String>>{};
    for (var subject in subjects) {
      uniqueSubjects[subject['name']!] = subject;
    }

    return uniqueSubjects.values.toList()..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  Widget _buildGroupedSubjectsSection() {
    final availableSubjects = _getAvailableSubjects();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PinkTheme.pink2.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: PinkTheme.pink2.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: PinkTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المواد الدراسية',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PinkTheme.pink2,
                      ),
                    ),
                    if (availableSubjects.isEmpty)
                      Text(
                        'اختر المراحل والصفوف أولاً',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (_selectedSubjects.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: PinkTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedSubjects.length}',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (availableSubjects.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'اختر المراحل والصفوف لعرض المواد المتاحة',
                      style: GoogleFonts.cairo(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableSubjects.map((subject) {
                final subjectName = subject['name']!;
                final emoji = subject['emoji']!;
                final isSelected = _selectedSubjects.contains(subjectName);
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSubjects.remove(subjectName);
                      } else {
                        _selectedSubjects.add(subjectName);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? PinkTheme.buttonGradient : null,
                      color: isSelected ? null : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: PinkTheme.pink2.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subjectName,
                          style: GoogleFonts.cairo(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, color: Colors.white, size: 18),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectSection({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PinkTheme.pink2.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: PinkTheme.pink2, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PinkTheme.pink2,
                ),
              ),
              const Spacer(),
              if (selectedItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PinkTheme.pink2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedItems.length}',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = selectedItems.contains(item);
              return InkWell(
                onTap: () {
                  final newList = List<String>.from(selectedItems);
                  if (isSelected) {
                    newList.remove(item);
                  } else {
                    newList.add(item);
                  }
                  onChanged(newList);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? PinkTheme.buttonGradient : null,
                    color: isSelected ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.white, size: 16),
                      if (isSelected) const SizedBox(width: 4),
                      Text(
                        item,
                        style: GoogleFonts.cairo(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
