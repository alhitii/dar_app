import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/education_constants.dart';
import '../../utils/pink_theme.dart';

class EditTeacherDialog extends StatefulWidget {
  final String teacherId;
  final Map<String, dynamic> teacherData;

  const EditTeacherDialog({
    super.key,
    required this.teacherId,
    required this.teacherData,
  });

  @override
  State<EditTeacherDialog> createState() => _EditTeacherDialogState();
}

class _EditTeacherDialogState extends State<EditTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  List<String> _selectedStages = [];
  List<String> _selectedGrades = [];
  List<String> _selectedBranches = [];
  List<String> _selectedSections = [];
  List<String> _selectedSubjects = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacherData['name']);
    
    // تحميل المراحل
    final stages = widget.teacherData['stages'];
    if (stages is List) {
      _selectedStages = List<String>.from(stages);
    }
    
    // تحميل الصفوف
    final grades = widget.teacherData['grades'];
    if (grades is List) {
      _selectedGrades = List<String>.from(grades);
    }
    
    // تحميل الفروع
    final branches = widget.teacherData['branches'];
    if (branches is List) {
      _selectedBranches = List<String>.from(branches);
    }
    
    // تحميل الشعب
    _selectedSections = List<String>.from(widget.teacherData['sections'] ?? []);
    
    // تحميل المواد
    final subjects = widget.teacherData['subjects'];
    if (subjects is List) {
      _selectedSubjects = List<String>.from(subjects);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getAvailableSubjects() {
    if (_selectedStages.isEmpty || _selectedGrades.isEmpty) {
      return [];
    }

    final subjects = <Map<String, String>>[];

    // مواد الابتدائية
    if (_selectedStages.contains('ابتدائية')) {
      subjects.addAll([
        {'name': 'اللغة العربية', 'emoji': '📖'},
        {'name': 'اللغة الإنجليزية', 'emoji': '🇬🇧'},
        {'name': 'التربية الإسلامية', 'emoji': '☪️'},
        {'name': 'الرياضيات', 'emoji': '📐'},
        {'name': 'العلوم', 'emoji': '🔬'},
        {'name': 'الرياضة', 'emoji': '⚽'},
        {'name': 'الفنية', 'emoji': '🎨'},
        {'name': 'التربية الأخلاقية', 'emoji': '💎'},
        {'name': 'الاجتماعيات', 'emoji': '🌍'},
      ]);
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
      
      // الحاسوب (الأول والثاني فقط - محذوف من الثالث)
      if (hasFirstOrSecond) {
        subjects.add({'name': 'الحاسوب', 'emoji': '💻'});
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

    final uniqueSubjects = <String, Map<String, String>>{};
    for (var subject in subjects) {
      uniqueSubjects[subject['name']!] = subject;
    }

    return uniqueSubjects.values.toList()..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

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

    try {
      final teacherData = {
        'name': _nameController.text.trim(),
        'stages': _selectedStages,
        'grades': _selectedGrades,
        'branches': _selectedBranches,
        'sections': _selectedSections,
        'subjects': _selectedSubjects,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // تحديث teachers collection - استبدال كامل بدون merge
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(widget.teacherId)
          .set(teacherData, SetOptions(merge: false));

      // تحديث users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.teacherId)
          .update({
        'name': _nameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث users_emails collection إذا كان موجوداً
      final email = widget.teacherData['email'];
      if (email != null) {
        await FirebaseFirestore.instance
            .collection('users_emails')
            .doc(email)
            .set({
          ...teacherData,
          'uid': widget.teacherId,
          'email': email,
        }, SetOptions(merge: false)); // استبدال كامل - حذف المواد القديمة!
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث بيانات المعلم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // العنوان
              Row(
                children: [
                  Text(
                    'تعديل بيانات المعلم',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              
              // المحتوى القابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الاسم
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: const Color(0xFF2C3E50),
                        ),
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          labelStyle: GoogleFonts.cairo(
                            color: const Color(0xFF7F8C8D),
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: PinkTheme.pink2, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // المراحل
                      Text(
                        'المراحل:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: PinkTheme.pink2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: EducationConstants.stages.map((stage) {
                          final isSelected = _selectedStages.contains(stage);
                          return FilterChip(
                            label: Text(stage, style: GoogleFonts.cairo(color: Colors.black87)),
                            selected: isSelected,
                            selectedColor: PinkTheme.pink2.withOpacity(0.3),
                            checkmarkColor: PinkTheme.pink2,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedStages.add(stage);
                                } else {
                                  _selectedStages.remove(stage);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // الصفوف
                      Text(
                        'الصفوف:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: PinkTheme.pink2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'].map((grade) {
                          final isSelected = _selectedGrades.contains(grade);
                          return FilterChip(
                            label: Text(grade, style: GoogleFonts.cairo(color: Colors.black87)),
                            selected: isSelected,
                            selectedColor: PinkTheme.pink2.withOpacity(0.3),
                            checkmarkColor: PinkTheme.pink2,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedGrades.add(grade);
                                } else {
                                  _selectedGrades.remove(grade);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // الفروع (للإعدادية)
                      if (_selectedStages.contains('إعدادية')) ...[
                        Text(
                          'الفروع:',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: PinkTheme.pink2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: EducationConstants.branches.map((branch) {
                            final isSelected = _selectedBranches.contains(branch);
                            return FilterChip(
                              label: Text(branch, style: GoogleFonts.cairo(color: Colors.black87)),
                              selected: isSelected,
                              selectedColor: PinkTheme.pink2.withOpacity(0.3),
                              checkmarkColor: PinkTheme.pink2,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedBranches.add(branch);
                                  } else {
                                    _selectedBranches.remove(branch);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // الشعب
                      Text(
                        'الشعب:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: EducationConstants.sections.map((section) {
                          final isSelected = _selectedSections.contains(section);
                          return FilterChip(
                            label: Text(section, style: GoogleFonts.cairo(color: Colors.black87)),
                            selected: isSelected,
                            selectedColor: PinkTheme.pink2.withOpacity(0.3),
                            checkmarkColor: PinkTheme.pink2,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSections.add(section);
                                } else {
                                  _selectedSections.remove(section);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // المواد
                      Text(
                        'المواد:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: PinkTheme.pink2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final availableSubjects = _getAvailableSubjects();
                          
                          if (availableSubjects.isEmpty) {
                            return Text(
                              'اختر المراحل والصفوف لعرض المواد',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF7F8C8D),
                                fontSize: 14,
                              ),
                            );
                          }
                          
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableSubjects.map((subject) {
                              final subjectName = subject['name']!;
                              final emoji = subject['emoji']!;
                              final isSelected = _selectedSubjects.contains(subjectName);
                              
                              return FilterChip(
                                label: Text('$emoji $subjectName', style: GoogleFonts.cairo(color: Colors.black87)),
                                selected: isSelected,
                                selectedColor: PinkTheme.pink2.withOpacity(0.3),
                                checkmarkColor: PinkTheme.pink2,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSubjects.add(subjectName);
                                    } else {
                                      _selectedSubjects.remove(subjectName);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const Divider(),
              
              // أزرار الحفظ والإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text('إلغاء', style: GoogleFonts.cairo()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PinkTheme.pink2,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('حفظ التغييرات', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
