import 'package:attendance_tracker/view/backup_screen.dart';
import 'package:attendance_tracker/view/home_screen.dart';
import 'package:attendance_tracker/view/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';

class MainBottomNavScreen extends StatefulWidget {
  @override
  _MainBottomNavScreenState createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // 2. ADD the BackupScreen to the list of screens
  final List<Widget> _screens = [HomeScreen(), TimetableScreen(), BackupScreen()];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: isTablet ? sh * 0.12 : sh * 0.1,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isTablet ? 20 : 15,
              offset: Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isTablet ? sw * 0.06 : sw * 0.05),
            topRight: Radius.circular(isTablet ? sw * 0.06 : sw * 0.05),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: isTablet ? sh * 0.018 : sh * 0.015,
            unselectedFontSize: isTablet ? sh * 0.015 : sh * 0.012,
            elevation: 0,
            iconSize: isTablet ? sw * 0.045 : sw * 0.06,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? sh * 0.018 : sh * 0.015,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? sh * 0.015 : sh * 0.012,
            ),
            // 3. ADD a third BottomNavigationBarItem
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sh * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.03 : sw * 0.025),
                  ),
                  child: Icon(
                    _currentIndex == 0
                        ? Icons.checklist_rtl
                        : Icons.checklist_rtl_outlined,
                    size: isTablet ? sw * 0.07 : sw * 0.06,
                  ),
                ),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sh * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.03 : sw * 0.025),
                  ),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.schedule
                        : Icons.schedule_outlined,
                    size: isTablet ? sw * 0.07 : sw * 0.06,
                  ),
                ),
                label: 'Timetable',
              ),
              // START: New Backup Tab Item
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sh * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: _currentIndex == 2 // Check for the new index
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.03 : sw * 0.025),
                  ),
                  child: Icon(
                    _currentIndex == 2
                        ? Icons.backup
                        : Icons.backup_outlined, // Use backup icons
                    size: isTablet ? sw * 0.07 : sw * 0.06,
                  ),
                ),
                label: 'Backup',
              ),
              // END: New Backup Tab Item
            ],
          ),
        ),
      ),
    );
  }
}
