// Splash Screen - Fully Responsive
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';
import 'package:attendance_tracker/view/bottom_bar_screen.dart';
import 'package:attendance_tracker/view/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    Future.delayed(Duration(milliseconds: 500), () {
      _rotationController.repeat();
    });
    Future.delayed(Duration(milliseconds: 800), () {
      _progressController.forward();
    });

    _checkUserData();
  }

  _checkUserData() async {
    await Future.delayed(Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');

    if (userData != null) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainBottomNavScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
        (route) => false, // This removes all previous routes
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LandingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
        (route) => false, // This removes all previous routes
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: sw,
        height: sh,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo Container
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 0.1,
                          child: Container(
                            width: isTablet ? sw * 0.2 : sw * 0.3,
                            height: isTablet ? sw * 0.2 : sw * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                isTablet ? sw * 0.05 : sw * 0.075,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: isTablet ? 20 : 15,
                                  offset: Offset(0, isTablet ? 10 : 8),
                                  spreadRadius: isTablet ? 2 : 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school,
                              size: isTablet ? sw * 0.1 : sw * 0.15,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: sh * 0.04),

                    // App Title
                    Container(
                      width: isTablet ? sw * 0.8 : sw * 0.9,
                      child: Text(
                        'Attendance Tracker',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bold(
                          context,
                          isTablet ? 32 : 28,
                          Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.015),

                    // Subtitle
                    Container(
                      width: isTablet ? sw * 0.7 : sw * 0.8,
                      child: Text(
                        'Track your college attendance',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regular(
                          context,
                          isTablet ? 18 : 16,
                          Colors.white70,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.06),

                    // Loading Indicator with Animation
                    Column(
                      children: [
                        SizedBox(
                          width: isTablet ? sw * 0.15 : sw * 0.2,
                          height: isTablet ? sw * 0.15 : sw * 0.2,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Circle
                              Container(
                                width: isTablet ? sw * 0.15 : sw * 0.2,
                                height: isTablet ? sw * 0.15 : sw * 0.2,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Animated Progress Indicator
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return CircularProgressIndicator(
                                    value: _progressAnimation.value,
                                    strokeWidth: isTablet ? 4 : 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    backgroundColor:
                                        Colors.white.withOpacity(0.3),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: sh * 0.025),

                        // Loading Text
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Text(
                              'Loading... ${(_progressAnimation.value * 100).toInt()}%',
                              style: AppTextStyles.medium(
                                context,
                                isTablet ? 16 : 14,
                                Colors.white70,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.08),

                    // Bottom Branding (for tablets)
                    if (isTablet) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.1,
                          vertical: sh * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(sw * 0.05),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: isTablet ? 20 : 16,
                            ),
                            SizedBox(width: sw * 0.02),
                            Text(
                              'Student Friendly App',
                              style: AppTextStyles.medium(
                                context,
                                isTablet ? 14 : 12,
                                Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
