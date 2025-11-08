import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SendAbsenceScreen extends StatefulWidget {
  final String studentUid;
  final String studentName;
  final String studentGrade;
  final String studentSection;

  const SendAbsenceScreen({
    super.key,
    required this.studentUid,
    required this.studentName,
    required this.studentGrade,
    required this.studentSection,
  });

  @override
  State<SendAbsenceScreen> createState() => _SendAbsenceScreenState();
}

class _SendAbsenceScreenState extends State<SendAbsenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E5C8A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _sendAbsence() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(hours: 24));
      final archiveDate = now.add(const Duration(days: 365));

      // إرسال إلى notifications_absences
      await FirebaseFirestore.instance
          .collection('notifications_absences')
          .add({
        'studentUid': widget.studentUid,
        'studentName': widget.studentName,
        'message': _messageController.text.trim(),
        'date': _selectedDate,
        'createdAt': now,
        'bannerExpiresAt': expiryDate,  // يظهر في البانر لمدة 24 ساعة
        'archiveUntil': archiveDate,    // يبقى في التنبيهات لمدة سنة
        'read': false,
        'type': 'absence',
      });

      // حفظ في سجل الغيابات (لمدة سنة)
      await FirebaseFirestore.instance
          .collection('absences')
          .add({
        'studentUid': widget.studentUid,
        'studentName': widget.studentName,
        'studentGrade': widget.studentGrade,
        'studentSection': widget.studentSection,
        'message': _messageController.text.trim(),
        'absenceDate': _selectedDate,
        'createdAt': now,
        'archiveUntil': archiveDate,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ تم إرسال إشعار الغياب بنجاح',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ حدث خطأ في إرسال الإشعار',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'إرسال إشعار غياب',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة معلومات الطالب
              _buildStudentInfoCard(),

              const SizedBox(height: 24),

              // تاريخ الغياب
              _buildDatePicker(),

              const SizedBox(height: 16),

              // رسالة الغياب
              _buildMessageField(),

              const SizedBox(height: 16),

              // ملاحظة
              _buildNotice(),

              const SizedBox(height: 24),

              // زر الإرسال
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[200]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'إرسال إشعار غياب إلى:',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.studentName,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.studentGrade} - ${widget.studentSection}',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCEBF7),
        ),
      ),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF2E5C8A),
            ),
            Text(
              DateFormat('dd/MM/yyyy', 'ar').format(_selectedDate),
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'تاريخ الغياب',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCEBF7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'رسالة الغياب',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب رسالة الغياب هنا...',
              hintStyle: GoogleFonts.cairo(
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
              contentPadding: const EdgeInsets.all(12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء كتابة رسالة الغياب';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '💡 سيظهر الإشعار في الصفحة الرئيسية للطالب لمدة 24 ساعة، وسيبقى في سجل الغيابات لمدة سنة كاملة.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.orange[900],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.info_outline,
            color: Colors.orange[700],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Color(0xFFE53935)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _sendAbsence,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إرسال إشعار الغياب',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
