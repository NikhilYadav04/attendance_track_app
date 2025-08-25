// Landing Screen with Animations - Fully Responsive
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/view/auth_screen.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    Future.delayed(Duration(milliseconds: 600), () {
      _bounceController.forward();
    });
    Future.delayed(Duration(milliseconds: 1500), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sh * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon Container
              ScaleTransition(
                scale: _bounceAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: isTablet ? sw * 0.25 : sw * 0.4,
                        height: isTablet ? sw * 0.25 : sw * 0.4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            isTablet ? sw * 0.06 : sw * 0.08,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: isTablet ? 30 : 25,
                              offset: Offset(0, isTablet ? 15 : 12),
                              spreadRadius: isTablet ? 3 : 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.school,
                          size: isTablet ? sw * 0.12 : sw * 0.2,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: sh * 0.06),

              // Text Content with Animations
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Welcome Text
                      Text(
                        'Welcome to',
                        style: AppTextStyles.regular(
                          context,
                          isTablet ? 24 : 20,
                          AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: sh * 0.01),

                      // App Title
                      Container(
                        width: isTablet ? sw * 0.8 : sw,
                        child: Text(
                          'Attendance Tracker',
                          style: AppTextStyles.bold(
                            context,
                            isTablet ? 38 : 32,
                            AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: sh * 0.03),

                      // Description
                      Container(
                        width: isTablet ? sw * 0.7 : sw * 0.9,
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 600 : 400,
                        ),
                        child: Text(
                          'Keep track of your college attendance easily and never miss your target percentage!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regular(
                            context,
                            isTablet ? 18 : 16,
                            AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: sh * 0.08),

              // Get Started Button
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: isTablet ? sw * 0.5 : sw * 0.8,
                  height: isTablet ? sh * 0.08 : sh * 0.07,
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 400 : 300,
                    minHeight: isTablet ? 65 : 55,
                    maxHeight: isTablet ? 75 : 65,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              AuthScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: Duration(milliseconds: 300),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isTablet ? 20 : 15,
                        ),
                      ),
                      elevation: isTablet ? 12 : 8,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.08,
                        vertical: sh * 0.02,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: AppTextStyles.medium(
                            context,
                            isTablet ? 20 : 18,
                            Colors.white,
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Icon(
                          Icons.arrow_forward,
                          size: isTablet ? 24 : 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.05),

              // Additional decorative elements for tablets
              if (isTablet) ...[
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeatureIcon(Icons.check_circle, sw),
                        SizedBox(width: sw * 0.08),
                        _buildFeatureIcon(Icons.trending_up, sw),
                        SizedBox(width: sw * 0.08),
                        _buildFeatureIcon(Icons.notifications, sw),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.02),
                Text(
                  'Track • Analyze • Success',
                  style: AppTextStyles.medium(
                    context,
                    14,
                    AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, double sw) {
    return Container(
      width: sw * 0.12,
      height: sw * 0.12,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Icon(
        icon,
        size: sw * 0.06,
        color: AppColors.secondary,
      ),
    );
  }
}