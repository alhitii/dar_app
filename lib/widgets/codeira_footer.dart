import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CodeiraFooter extends StatelessWidget {
  final double fontSize;
  final Color textColor;
  final Color codeiraColor;
  final bool hasUnderline;
  final bool hasShadow;

  const CodeiraFooter({
    super.key,
    this.fontSize = 14,
    this.textColor = Colors.white,
    this.codeiraColor = const Color(0xFFE289DB),
    this.hasUnderline = true,
    this.hasShadow = true,
  });

  Future<void> _openCodeiraFacebook() async {
    final Uri url = Uri.parse('https://www.facebook.com/codeira');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('⚠️ لا يمكن فتح الرابط: $url');
      }
    } catch (e) {
      print('❌ خطأ في فتح الرابط: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Developed by ',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: textColor,
                shadows: hasShadow
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            InkWell(
              onTap: _openCodeiraFacebook,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  'Codeira',
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    color: codeiraColor,
                    fontWeight: FontWeight.w700,
                    decoration: hasUnderline ? TextDecoration.underline : null,
                    shadows: hasShadow
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
