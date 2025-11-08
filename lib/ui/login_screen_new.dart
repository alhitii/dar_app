import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/pink_theme.dart';
import '../../services/notification_service.dart';
import '../../widgets/codeira_footer.dart';

class LoginScreenNew extends StatefulWidget {
  const LoginScreenNew({super.key});

  @override
  State<LoginScreenNew> createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends State<LoginScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String email = _emailController.text.trim();
      // اسم مستخدم → نضيف الدومين
      if (!email.contains('@')) {
        email = '$email@codeira.com';
      }

      // منع حساب gg
      if (email.toLowerCase() == 'gg@codeira.com') {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'هذا الحساب غير صالح',
        );
      }

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );

      // جلب الدور أولاً
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      final role = userDoc.exists ? (userDoc.data()?['role'] ?? 'student') : 'student';

      // ✅ الاشتراك في Topics بدلاً من حفظ FCM Token (طريقة المشروع القديم)
      try {
        // جلب بيانات المستخدم للاشتراك في Topics
        final userData = {
          'uid': userCredential.user!.uid,
          'role': role,
          'grade': userDoc.data()?['grade'] ?? '',
          'section': userDoc.data()?['section'] ?? '',
        };
        
        // الاشتراك في Topics المناسبة
        await NotificationService.instance.subscribeForUser(userData);
        
        print('✅ تم الاشتراك في Topics بنجاح');
      } catch (e) {
        print('⚠️ خطأ في الاشتراك في Topics: $e');
      }

      // حفظ الدخول
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('userEmail', _emailController.text.trim());
      }

      if (!mounted) return;

      // استخدام role المحفوظ مسبقاً
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, '/teacher');
      } else {
        Navigator.pushReplacementNamed(context, '/student');
      }
    } on FirebaseAuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ البريد الإلكتروني أو كلمة المرور غير صحيحة',
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية بيضاء
          Container(color: Colors.white),

          // نصف الدائرة العلوية (تدرج وردي)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _CurvedTopClipper(),
              child: Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFADEC4),
                      Color(0xFFFFB5CC),
                      Color(0xFFE289DB),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // نصف الدائرة السفلية
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _CurvedBottomClipper(),
              child: Container(
                height: 130,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Color(0xFFE289DB),
                      Color(0xFFFFB5CC),
                      Color(0xFFFADEC4),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildLogoCard(),
                  const SizedBox(height: 40),
                  _buildLoginCard(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: PinkTheme.glassEffect(opacity: 0.85),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'assets/icon_foreground.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ثانوية دار السلام للبنات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3E50),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, // ✅ الكارد صار أبيض صافي
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFAD4E3).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE289DB).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.login_outlined,
                  color: PinkTheme.pink2,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'تسجيل الدخول',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PinkTheme.pink2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _emailController,
              hint: 'اسم المستخدم',
              icon: Icons.person_outline,
              keyboardType: TextInputType.text,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'الرجاء إدخال اسم المستخدم'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              hint: 'كلمة المرور',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: PinkTheme.pink2,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'الرجاء إدخال كلمة المرور';
                if (value.length < 6)
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                  activeColor: PinkTheme.pink2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'حفظ معلومات تسجيل الدخول',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white, // ✅ أبيض 100%
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent, // ✅ لا رمادي
          width: 0,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3E50)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: PinkTheme.pink2, size: 22),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: PinkTheme.buttonGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: PinkTheme.pink2.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _login,
          borderRadius: BorderRadius.circular(15),
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
                        'دخول',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_back_ios, // ✅ باتجاه العربي
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: const SafeArea(
        top: false,
        child: CodeiraFooter(
          fontSize: 14,
          textColor: Colors.white,
          codeiraColor: Color(0xFFE289DB),
          hasUnderline: true,
          hasShadow: false,
        ),
      ),
    );
  }
}

// 🔻 المنحنيات
class _CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
