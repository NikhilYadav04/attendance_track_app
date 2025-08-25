// Auth Screen - Fully Responsive with Rive Animation
import 'dart:convert';

import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';
import 'package:attendance_tracker/http/models/user.dart';
import 'package:attendance_tracker/view/bottom_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _collegeController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  //* Rive Animation
  String riveURL = "assets/animated_login_character.riv";
  SMITrigger? successTrigger, failTrigger;
  SMIBool? isChecking, isHandsUp;
  SMINumber? lookNum;
  StateMachineController? _stateMachineController;
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });

    //* load rive variables
    rootBundle.load(riveURL).then((value) {
      print("✅ Rive file loaded successfully");

      final file = RiveFile.import(value);
      final art = file.mainArtboard;

      print("✅ Artboard loaded: ${art.name}");

      _stateMachineController =
          StateMachineController.fromArtboard(art, "Login Machine");

      if (_stateMachineController != null) {
        print("✅ State machine controller created for 'Login Machine'");

        art.addController(_stateMachineController!);

        print("🔍 Available inputs:");
        _stateMachineController!.inputs.forEach((element) {
          print(
              "   Input name: '${element.name}', Type: ${element.runtimeType}");

          if (element.name == "isChecking") {
            isChecking = element as SMIBool;
            print("   ✅ isChecking found and assigned");
          } else if (element.name == "isHandsUp") {
            isHandsUp = element as SMIBool;
            print("   ✅ isHandsUp found and assigned");
          } else if (element.name == "trigSuccess") {
            successTrigger = element as SMITrigger;
            print("   ✅ trigSuccess found and assigned");
          } else if (element.name == "trigFail") {
            failTrigger = element as SMITrigger;
            print("   ✅ trigFail found and assigned");
          } else if (element.name == "numLook") {
            lookNum = element as SMINumber;
            print("   ✅ numLook found and assigned");
          }
        });

        print("📊 Final assignments:");
        print("   isChecking: ${isChecking != null ? '✅' : '❌'}");
        print("   isHandsUp: ${isHandsUp != null ? '✅' : '❌'}");
        print("   successTrigger: ${successTrigger != null ? '✅' : '❌'}");
        print("   failTrigger: ${failTrigger != null ? '✅' : '❌'}");
        print("   lookNum: ${lookNum != null ? '✅' : '❌'}");
      } else {
        print(
            "❌ Failed to create state machine controller for 'Login Machine'");
      }

      setState(() {
        _artboard = art;
      });
    }).catchError((error) {
      print("❌ Error loading Rive file: $error");
    });

    // Add listeners for text field changes
    _nameController.addListener(() {
      print("📝 Name field changed: '${_nameController.text}'");
      moveEyes(_nameController.text);
    });
    _nicknameController.addListener(() {
      print("📝 Nickname field changed: '${_nicknameController.text}'");
      moveEyes(_nicknameController.text);
    });
    _collegeController.addListener(() {
      print("📝 College field changed: '${_collegeController.text}'");
      moveEyes(_collegeController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _collegeController.dispose();
    _stateMachineController?.dispose();
    super.dispose();
  }

  //* animation functions
  void lookAround() {
    print("👀 lookAround() called");
    print("   isChecking: ${isChecking != null ? 'available' : 'null'}");
    print("   isHandsUp: ${isHandsUp != null ? 'available' : 'null'}");
    print("   lookNum: ${lookNum != null ? 'available' : 'null'}");

    isChecking?.change(true);
    isHandsUp?.change(false);
    lookNum?.change(0);

    print("   ✅ lookAround() executed");
  }

  void moveEyes(String value) {
    print("👁️ moveEyes() called with text length: ${value.length}");
    if (lookNum != null) {
      lookNum?.change(value.length.toDouble());
      print("   ✅ Eyes moved to: ${value.length}");
    } else {
      print("   ❌ lookNum is null - cannot move eyes");
    }
  }

  void handsUpOnEyes() {
    print("🙈 handsUpOnEyes() called");
    print("   isHandsUp: ${isHandsUp != null ? 'available' : 'null'}");
    print("   isChecking: ${isChecking != null ? 'available' : 'null'}");

    isHandsUp?.change(true);
    isChecking?.change(false);

    print("   ✅ handsUpOnEyes() executed");
  }

  void loginClick() {
    // 1) tell the bear we’re checking
    isChecking?.change(true);
    isHandsUp?.change(false);

    // 2) give the state machine a moment to transition
    Future.delayed(Duration(milliseconds: 300), () {
      if (_nameController.text.isNotEmpty &&
          _nicknameController.text.isNotEmpty &&
          _collegeController.text.isNotEmpty) {
        // 3a) success path
        successTrigger?.fire();
      } else {
        // 3b) failure path
        // put its hands over its eyes (sad/shy)
        //isHandsUp?.change(true);
        failTrigger?.fire();
      }

      // 4) after the trigger, drop out of the checking state
      Future.delayed(Duration(milliseconds: 800), () {
        isChecking?.change(false);
      });
    });
  }

  _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      loginClick(); // Trigger animation

      // Wait a bit for animation
      await Future.delayed(Duration(milliseconds: 500));

      UserData userData = UserData(
        name: _nameController.text,
        nickname: _nicknameController.text,
        collegeName: _collegeController.text,
        subjects: [],
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData.toJson()));

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainBottomNavScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
          transitionDuration: Duration(milliseconds: 400),
        ),
        (route) => false, // Remove all previous routes
      );
    } else {
      loginClick(); // Trigger fail animation for validation errors
    }
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isTablet ? sh * 0.08 : sh * 0.07,
        leading: Container(
          margin: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: isTablet ? sw * 0.035 : sw * 0.055,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              width: sw,
              constraints: BoxConstraints(minHeight: sh * 0.85),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sh * 0.02,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rive Animation
                      if (_artboard != null) ...[
                        SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            height: isTablet ? sh * 0.25 : sh * 0.2,
                            margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.04 : sw * 0.05),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: isTablet ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: isTablet ? 20 : 15,
                                  offset: Offset(0, isTablet ? 8 : 6),
                                  spreadRadius: isTablet ? 2 : 1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.04 : sw * 0.05),
                              child: Rive(
                                artboard: _artboard!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: sh * 0.02),
                      ],

                      // Header Section
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: isTablet ? sw * 0.8 : sw,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome Icon

                              SizedBox(height: sh * 0.025),

                              // Main Title
                              Text(
                                'Tell us about yourself',
                                style: AppTextStyles.bold(
                                  context,
                                  isTablet ? 32 : 28,
                                  AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: sh * 0.015),

                              // Subtitle
                              Text(
                                'We need some basic information to get started',
                                style: AppTextStyles.regular(
                                  context,
                                  isTablet ? 18 : 16,
                                  AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.025),

                      // Form Fields
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildTextField(
                              context: context,
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              icon: Icons.person,
                              sw: sw,
                              sh: sh,
                              isTablet: isTablet,
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  lookAround();
                                }
                              },
                            ),
                            SizedBox(height: sh * 0.025),
                            _buildTextField(
                              context: context,
                              controller: _nicknameController,
                              label: 'Nickname',
                              hint: 'What should we call you?',
                              icon: Icons.tag_faces,
                              sw: sw,
                              sh: sh,
                              isTablet: isTablet,
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  lookAround();
                                }
                              },
                            ),
                            SizedBox(height: sh * 0.025),
                            _buildTextField(
                              context: context,
                              controller: _collegeController,
                              label: 'College/School Name',
                              hint: 'Enter your institution name',
                              icon: Icons.school,
                              sw: sw,
                              sh: sh,
                              isTablet: isTablet,
                              isPassword: true, // This will trigger hands up
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  handsUpOnEyes();
                                } else {
                                  lookAround();
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      // Continue Button
                      ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: Container(
                          width: double.infinity,
                          height: isTablet ? sh * 0.08 : sh * 0.07,
                          constraints: BoxConstraints(
                            minHeight: isTablet ? 65 : 55,
                            maxHeight: isTablet ? 75 : 65,
                          ),
                          child: ElevatedButton(
                            onPressed: _saveUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isTablet ? 18 : 15,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
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

                      SizedBox(height: sh * 0.03),

                      // Footer Info (for tablets)
                      if (isTablet) ...[
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.06,
                              vertical: sh * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(sw * 0.03),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.security,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                                SizedBox(width: sw * 0.02),
                                Text(
                                  'Your data is stored locally and secure',
                                  style: AppTextStyles.medium(
                                    context,
                                    14,
                                    AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required double sw,
    required double sh,
    required bool isTablet,
    bool isPassword = false,
    Function(bool)? onFocusChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.medium(
            context,
            isTablet ? 18 : 16,
            AppColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.01),
        Container(
          height: isTablet ? sh * 0.08 : sh * 0.075,
          child: Focus(
            onFocusChange: onFocusChange,
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              style: AppTextStyles.regular(
                context,
                isTablet ? 18 : 16,
                AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.regular(
                  context,
                  isTablet ? 16 : 14,
                  AppColors.textSecondary,
                ),
                prefixIcon: Container(
                  width: isTablet ? sw * 0.12 : sw * 0.15,
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: isTablet ? sw * 0.04 : sw * 0.055,
                  ),
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04,
                  vertical: sh * 0.02,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  borderSide: BorderSide(color: AppColors.accent, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                if (controller == _nameController && value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                if (controller == _nicknameController && value.length < 2) {
                  return 'Nickname must be at least 2 characters';
                }
                if (controller == _collegeController && value.length < 3) {
                  return 'College name must be at least 3 characters';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
