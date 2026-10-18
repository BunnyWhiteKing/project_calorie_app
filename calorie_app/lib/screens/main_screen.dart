import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'tabs/tab1_food_screen.dart';
import 'tabs/tab2_goals_screen.dart';
import 'tabs/tab3_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    Tab1FoodScreen(),
    Tab2GoalsScreen(),
    Tab3ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().userProfile;
    final dailyGoal = user?.dailyCalorieGoal.toStringAsFixed(0) ?? '0';
    final bmi = user?.bmi.toStringAsFixed(1) ?? '0.0';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_fire_department, size: 28, color: Colors.amberAccent),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เป้าหมายวันนี้: $dailyGoal kcal',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'BMI ปัจจุบัน: $bmi',
                  style: TextStyle(fontSize: 13, color: Colors.teal.shade50),
                ),
              ],
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          indicatorColor: Colors.teal.shade100,
          backgroundColor: Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant, color: Colors.teal),
              label: 'คำนวณอาหาร',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: Colors.teal),
              label: 'เป้าหมาย',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Colors.teal),
              label: 'โปรไฟล์',
            ),
          ],
        ),
      ),
    );
  }
}