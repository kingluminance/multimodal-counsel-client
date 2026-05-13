import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../pages/home_page.dart';
import '../pages/client_page.dart';
import '../pages/schedule_page.dart';
import '../pages/notification_page.dart';
import '../pages/profile_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int _unreadCount = 3; // 읽지 않은 알림 수

  static const _pages = [
    HomePage(),
    ClientPage(),
    SchedulePage(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
              // 알림 탭 진입 시 읽음 처리 (실제 앱에서는 API 호출)
              if (i == 3) _unreadCount = 0;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: '내담자',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: '일정',
            ),
            BottomNavigationBarItem(
              icon: _NotifIcon(count: _unreadCount, isActive: false),
              activeIcon: _NotifIcon(count: _unreadCount, isActive: true),
              label: '알림',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifIcon extends StatelessWidget {
  final int count;
  final bool isActive;

  const _NotifIcon({required this.count, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isActive ? Icons.notifications : Icons.notifications_outlined,
          size: 24,
        ),
        if (count > 0)
          Positioned(
            top: -3,
            right: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.navBadge,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: count > 9
                  ? null
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}
