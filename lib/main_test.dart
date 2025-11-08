import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدرسة دار السلام - اختبار الثيم',
      debugShowCheckedModeBanner: false,
      
      // نظام الثيم الموحد
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      home: const TestHomeScreen(),
    );
  }
}

class TestHomeScreen extends StatefulWidget {
  const TestHomeScreen({super.key});

  @override
  State<TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<TestHomeScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<Widget> _pages = [
    const HomePage(),
    const SubjectsPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ثانوية دار السلام للبنات'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
              // يمكن هنا تطبيق الثيم الداكن
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'المواد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}

// صفحة الرئيسية
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBlue,
            AppColors.lightBlue,
            Color(0xFFFFE5EC),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // كارد الترحيب
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.school, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'مرحباً بك',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('ثانوية دار السلام للبنات'),
                  const SizedBox(height: 4),
                  Text(
                    'تأسست سنة 1966',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // الواجبات
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.primaryBlue),
              title: const Text('الواجبات'),
              subtitle: const Text('3 واجبات جديدة'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          
          // الغياب
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.orange),
              title: const Text('الحضور'),
              subtitle: const Text('لا يوجد غياب'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          
          // الدرجات
          Card(
            child: ListTile(
              leading: const Icon(Icons.grade, color: Colors.green),
              title: const Text('الدرجات'),
              subtitle: const Text('عرض الدرجات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Footer
          const Center(
            child: Text(
              'Developed by Codeira',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// صفحة المواد
class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {'name': 'الإسلامية', 'emoji': '🕌', 'color': Colors.green},
      {'name': 'العربية', 'emoji': '📖', 'color': Colors.brown},
      {'name': 'الإنكليزية', 'emoji': '🇬🇧', 'color': Colors.blue},
      {'name': 'الرياضيات', 'emoji': '🧮', 'color': Colors.purple},
      {'name': 'الكيمياء', 'emoji': '⚗️', 'color': Colors.teal},
      {'name': 'الفيزياء', 'emoji': '🔬', 'color': Colors.indigo},
      {'name': 'الأحياء', 'emoji': '🧬', 'color': Colors.lightGreen},
      {'name': 'الحاسوب', 'emoji': '💻', 'color': Colors.blueGrey},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subject['emoji'] as String,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  subject['name'] as String,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// صفحة الإشعارات
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Icon(
                index % 2 == 0 ? Icons.assignment : Icons.announcement,
                color: Colors.white,
              ),
            ),
            title: Text('إشعار ${index + 1}'),
            subtitle: const Text('وصلك إشعار جديد'),
            trailing: const Text('اليوم'),
          ),
        );
      },
    );
  }
}

// صفحة الملف الشخصي
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // الصورة الشخصية
        const Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        
        // الاسم
        Card(
          child: ListTile(
            leading: const Icon(Icons.person, color: AppColors.primaryBlue),
            title: const Text('الاسم'),
            subtitle: const Text('طالبة اختبار'),
          ),
        ),
        const SizedBox(height: 8),
        
        // المرحلة
        Card(
          child: ListTile(
            leading: const Icon(Icons.school, color: AppColors.primaryBlue),
            title: const Text('المرحلة'),
            subtitle: const Text('إعدادية - علمي'),
          ),
        ),
        const SizedBox(height: 8),
        
        // الصف
        Card(
          child: ListTile(
            leading: const Icon(Icons.class_, color: AppColors.primaryBlue),
            title: const Text('الصف'),
            subtitle: const Text('السادس - أ'),
          ),
        ),
        const SizedBox(height: 24),
        
        // زر تسجيل الخروج
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout),
          label: const Text('تسجيل الخروج'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
