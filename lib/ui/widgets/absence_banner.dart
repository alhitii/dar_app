import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsenceBanner extends StatelessWidget {
  final String message;
  final String? date;
  final String? sentTime;
  final VoidCallback? onTap;

  const AbsenceBanner({
    super.key,
    this.message = 'تم تسجيل غيابك اليوم',
    this.date,
    this.sentTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 🔥 تدرج أحمر ملفت للنظر
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF1744), // أحمر نيون ساطع
            Color(0xFFD50000), // أحمر غامق
            Color(0xFF9C1010), // أحمر داكن جداً
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        // حد أحمر مضيء
        border: Border.all(
          color: const Color(0xFFFF5252).withOpacity(0.6),
          width: 2,
        ),
        // ظلال متعددة للعمق
        boxShadow: [
          // ظل أحمر قوي
          BoxShadow(
            color: const Color(0xFFFF1744).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
          // ظل أحمر داخلي
          BoxShadow(
            color: const Color(0xFFD50000).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          // توهج أحمر خفيف
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // أيقونة خلفية كبيرة للتوهج
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 130,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 120,
                  color: Colors.yellow.withOpacity(0.1),
                ),
              ),
              
              // المحتوى الرئيسي
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف الأول: أيقونة + عنوان + تاريخ
                    Row(
                      children: [
                        // أيقونة مع توهج
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // العنوان
                        Expanded(
                          child: Text(
                            '⚠️ تنبيه غياب',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                                Shadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // شارة التاريخ
                        if (date != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  date!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // الرسالة
                    Text(
                      message,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // وقت الإرسال
                    if (sentTime != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'تم الإرسال: $sentTime',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
