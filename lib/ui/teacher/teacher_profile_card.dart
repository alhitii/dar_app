import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/pink_theme.dart';

// بطاقة معلومات المعلم
Widget buildTeacherProfileCard({
  required Map<String, dynamic>? teacherData,
  required List<Map<String, String>>? teacherSubjects,
}) {
  if (teacherData == null) {
    return const SizedBox.shrink();
  }

  final name = teacherData['name'] as String? ?? 'المعلم';
  
  // المراحل
  final stages = teacherData['stages'] as List<dynamic>?;
  final stagesStr = stages?.join('، ') ?? 'غير محدد';
  
  // الصفوف
  final grades = teacherData['grades'] as List<dynamic>?;
  final gradesStr = grades?.join('، ') ?? 'غير محدد';
  
  // الفروع
  final branches = teacherData['branches'] as List<dynamic>?;
  final branchesStr = branches?.isNotEmpty == true ? branches!.join('، ') : '';
  
  // الشعب
  final sections = teacherData['sections'] as List<dynamic>?;
  final sectionsStr = sections?.join('، ') ?? 'غير محدد';
  
  // المواد - استخدام المواد من teacherData
  final subjects = teacherData['subjects'] as List<dynamic>?;
  final subjectsStr = subjects?.join('، ') ?? 'لا توجد مواد';

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          PinkTheme.pink2.withOpacity(0.9),
          const Color(0xFF4DB6AC).withOpacity(0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: PinkTheme.pink2.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الاسم
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أ : $name',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'معلم/ة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        const Divider(color: Colors.white38, thickness: 1),
        const SizedBox(height: 16),
        
        // المراحل
        _buildInfoRow(
          Icons.school,
          'المراحل',
          stagesStr,
        ),
        
        const SizedBox(height: 12),
        
        // الصفوف
        _buildInfoRow(
          Icons.grade,
          'الصفوف',
          gradesStr,
        ),
        
        const SizedBox(height: 12),
        
        // الفروع (إن وجدت)
        if (branchesStr.isNotEmpty) ...[
          _buildInfoRow(
            Icons.account_tree,
            'الفروع',
            branchesStr,
          ),
          const SizedBox(height: 12),
        ],
        
        // الشعب
        _buildInfoRow(
          Icons.class_,
          'الشعب',
          sectionsStr,
        ),
        
        const SizedBox(height: 12),
        
        // المواد
        _buildInfoRow(
          Icons.book,
          'المواد',
          subjectsStr,
        ),
      ],
    ),
  );
}

// صف معلومات
Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
}
