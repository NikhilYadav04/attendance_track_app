import 'package:attendance_tracker/core/snackBar.dart';
import 'package:attendance_tracker/provider/backup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendance_tracker/core/appColors.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupScreen extends StatefulWidget {
  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  //* initialize provider
  late final BackupProvider _provider;

  //* boolean
  bool _isAuth = false;
  bool _isCreateBackup = false;
  bool _isRestoreBackup = false;
  bool _isDelete = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _provider = Provider.of<BackupProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: isTablet ? sh * 0.08 : sh * 0.07,
        title: Text(
          'Backup & Restore',
          style: AppTextStyles.bold(
            context,
            isTablet ? 20 : 18,
            Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: isTablet ? 26 : 24,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? userData = prefs.getString('user_data');
              Logger().d(userData);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.025,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Management',
                  style: AppTextStyles.bold(
                      context, isTablet ? 26 : 22, AppColors.textPrimary),
                ),
                SizedBox(height: sh * 0.008),
                Text(
                  'Secure your attendance data with backup and restore options',
                  style: AppTextStyles.regular(
                      context, isTablet ? 15 : 13, AppColors.textSecondary),
                ),
                SizedBox(height: sh * 0.03),

                // Register User Card
                _buildOptionCard(
                  context,
                  sw,
                  sh,
                  isTablet,
                  icon: Icons.person_add_outlined,
                  title: 'Register User',
                  subtitle:
                      'Register as a new user and get your unique key for data management.',
                  color: Colors.blue,
                  onTap: () => _showRegisterUserDialog(context),
                ),
                SizedBox(height: sh * 0.015),

                // Create Backup Card
                _buildOptionCard(
                  context,
                  sw,
                  sh,
                  isTablet,
                  icon: Icons.cloud_upload_outlined,
                  title: 'Create Backup',
                  subtitle:
                      'Save your current attendance data to a secure location for future recovery.',
                  color: AppColors.primary,
                  onTap: () => _showCreateBackupDialog(context),
                ),
                SizedBox(height: sh * 0.015),

                // Restore Backup Card
                _buildOptionCard(
                  context,
                  sw,
                  sh,
                  isTablet,
                  icon: Icons.cloud_download_outlined,
                  title: 'Restore from Backup',
                  subtitle:
                      'Restore your data using your unique backup key. Current data will be replaced.',
                  color: AppColors.success,
                  onTap: () => _showRestoreBackupDialog(context),
                ),
                SizedBox(height: sh * 0.015),

                // Delete Account Card
                _buildOptionCard(
                  context,
                  sw,
                  sh,
                  isTablet,
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle:
                      'Permanently delete your account and all associated data from our servers.',
                  color: AppColors.accent,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
                SizedBox(height: sh * 0.015),

                // Logout Card
                _buildOptionCard(
                  context,
                  sw,
                  sh,
                  isTablet,
                  icon: Icons.logout_outlined,
                  title: 'Logout',
                  subtitle:
                      'Sign out of your account and return to the login screen.',
                  color: Colors.orange,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),

          // Loading Dialog Overlay
          if (_isAuth || _isCreateBackup || _isRestoreBackup || _isDelete)
            _buildLoadingDialog(context, sw, sh, isTablet),
        ],
      ),
    );
  }

  Widget _buildLoadingDialog(
      BuildContext context, double sw, double sh, bool isTablet) {
    String title = '';
    String description = '';

    if (_isAuth) {
      title = 'Registering User';
      description = 'Please wait while we register your account...';
    } else if (_isCreateBackup) {
      title = 'Creating Backup';
      description = 'Please wait while we backup your data...';
    } else if (_isRestoreBackup) {
      title = 'Restoring Data';
      description = 'Please wait while we restore your data...';
    } else if (_isDelete) {
      title = 'Deleting Account';
      description = 'Please wait while we delete your account...';
    }

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(sw * (isTablet ? 0.06 : 0.08)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(sw * (isTablet ? 0.05 : 0.06)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
                SizedBox(height: sh * 0.025),
                Text(
                  title,
                  style: AppTextStyles.bold(
                    context,
                    isTablet ? 18 : 16,
                    AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: sh * 0.012),
                Text(
                  description,
                  style: AppTextStyles.regular(
                    context,
                    isTablet ? 14 : 12,
                    AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    double sw,
    double sh,
    bool isTablet, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * (isTablet ? 0.035 : 0.04)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.05 : 0.045)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: sw * 0.04,
              offset: Offset(0, sh * 0.008),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: sw * 0.008,
              offset: Offset(0, sh * 0.002),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: sw * (isTablet ? 0.12 : 0.14),
              height: sw * (isTablet ? 0.12 : 0.14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(sw * (isTablet ? 0.03 : 0.032)),
              ),
              child: Icon(icon,
                  color: color, size: sw * (isTablet ? 0.065 : 0.06)),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bold(
                        context, isTablet ? 18 : 16, AppColors.textPrimary),
                  ),
                  SizedBox(height: sh * 0.006),
                  Text(
                    subtitle,
                    style: AppTextStyles.regular(
                        context, isTablet ? 14 : 12, AppColors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.015),
            Container(
              padding: EdgeInsets.all(sw * 0.015),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary.withOpacity(0.6),
                size: sw * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.06 : 0.065)),
        ),
        child: Container(
          width: sw * 0.85,
          padding: EdgeInsets.all(sw * (isTablet ? 0.05 : 0.055)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * (isTablet ? 0.025 : 0.028)),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                          sw * (isTablet ? 0.035 : 0.038)),
                    ),
                    child: Icon(
                      Icons.logout_outlined,
                      color: Colors.orange,
                      size: sw * (isTablet ? 0.055 : 0.058),
                    ),
                  ),
                  SizedBox(width: sw * 0.025),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: AppTextStyles.bold(
                          context, isTablet ? 18 : 16, AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.025),
              Text(
                'Are you sure you want to logout?',
                style: AppTextStyles.regular(
                    context, isTablet ? 16 : 14, AppColors.textPrimary),
              ),
              SizedBox(height: sh * 0.008),
              Text(
                'You will need to sign in again to access your account.',
                style: AppTextStyles.regular(
                    context, isTablet ? 14 : 12, AppColors.textSecondary),
              ),
              SizedBox(height: sh * 0.025),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.025),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.medium(context, isTablet ? 15 : 14,
                            AppColors.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.025),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Store the main screen context before closing dialog
                        final mainScreenContext = this.context;

                        Navigator.of(context).pop();
                        _provider.logout(mainScreenContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.025),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: Colors.white,
                              size: sw * (isTablet ? 0.045 : 0.048)),
                          SizedBox(width: sw * 0.015),
                          Text(
                            'Logout',
                            style: AppTextStyles.medium(
                                context, isTablet ? 15 : 14, Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterUserDialog(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    bool sendEmail = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(sw * (isTablet ? 0.06 : 0.065)),
              ),
              child: Container(
                width: sw * 0.85,
                padding: EdgeInsets.all(sw * (isTablet ? 0.05 : 0.055)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.all(sw * (isTablet ? 0.025 : 0.028)),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(
                                  sw * (isTablet ? 0.035 : 0.038)),
                            ),
                            child: Icon(
                              Icons.person_add_outlined,
                              color: Colors.blue,
                              size: sw * (isTablet ? 0.055 : 0.058),
                            ),
                          ),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                            child: Text(
                              'Register User',
                              style: AppTextStyles.bold(context,
                                  isTablet ? 18 : 16, AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.03),
                      _buildModernTextField(
                        context,
                        sw,
                        sh,
                        isTablet,
                        controller: nameController,
                        label: 'Your Name',
                        hint: 'e.g., John Doe',
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: sh * 0.02),
                      Container(
                        padding: EdgeInsets.all(sw * 0.008),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: isTablet ? 1.1 : 0.9,
                              child: Checkbox(
                                value: sendEmail,
                                onChanged: (bool? value) => setDialogState(
                                    () => sendEmail = value ?? false),
                                activeColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.008),
                                ),
                              ),
                            ),
                            SizedBox(width: sw * 0.015),
                            Expanded(
                              child: Text(
                                "Send unique key to my email",
                                style: AppTextStyles.regular(context,
                                    isTablet ? 15 : 14, AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (sendEmail) ...[
                        SizedBox(height: sh * 0.015),
                        _buildModernTextField(
                          context,
                          sw,
                          sh,
                          isTablet,
                          controller: emailController,
                          label: 'Email Address',
                          hint: 'e.g., john.doe@email.com',
                          icon: Icons.email_outlined,
                        ),
                      ],
                      SizedBox(height: sh * 0.025),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    EdgeInsets.symmetric(vertical: sh * 0.018),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.025),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.medium(
                                    context,
                                    isTablet ? 15 : 14,
                                    AppColors.textSecondary),
                              ),
                            ),
                          ),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Store the main screen context BEFORE closing dialog
                                final mainScreenContext = this.context;

                                if (sendEmail &&
                                    emailController.text.trim().length == 0) {
                                  CustomSnackBar.show(
                                    context: context,
                                    icon: Icons.error,
                                    backgroundColor: Colors.red,
                                    title: "Enter a Email !",
                                  );
                                  return;
                                }

                                // Close dialog first
                                Navigator.of(context).pop();

                                // Set loader to true
                                setState(() {
                                  _isAuth = true;
                                });

                                // Create auth - use main screen context
                                String key = await _provider.registerUser(
                                    mainScreenContext,
                                    name: nameController.text.toString());

                                // In case of error
                                if (key == "0") {
                                  setState(() {
                                    _isAuth = false;
                                  });
                                  return;
                                }

                                if (sendEmail) {
                                  await _provider.sendEmail(
                                      context: mainScreenContext,
                                      email: emailController.text.trim(),
                                      uniqueKey: key.toString());
                                }

                                setState(() {
                                  _isAuth = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    EdgeInsets.symmetric(vertical: sh * 0.018),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.025),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add,
                                      color: Colors.white,
                                      size: sw * (isTablet ? 0.045 : 0.048)),
                                  SizedBox(width: sw * 0.015),
                                  Text(
                                    'Register',
                                    style: AppTextStyles.medium(context,
                                        isTablet ? 15 : 14, Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateBackupDialog(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    final nameController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw * (isTablet ? 0.06 : 0.065)),
          ),
          child: Container(
            width: sw * 0.85,
            padding: EdgeInsets.all(sw * (isTablet ? 0.05 : 0.055)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.all(sw * (isTablet ? 0.025 : 0.028)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                              sw * (isTablet ? 0.035 : 0.038)),
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.primary,
                          size: sw * (isTablet ? 0.055 : 0.058),
                        ),
                      ),
                      SizedBox(width: sw * 0.025),
                      Expanded(
                        child: Text(
                          'Create Backup',
                          style: AppTextStyles.bold(context, isTablet ? 18 : 16,
                              AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.03),
                  _buildModernTextField(
                    context,
                    sw,
                    sh,
                    isTablet,
                    controller: nameController,
                    label: 'Your Name',
                    hint: 'e.g., John Doe',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: sh * 0.02),
                  _buildModernTextField(
                    context,
                    sw,
                    sh,
                    isTablet,
                    controller: keyController,
                    label: 'Your Unique Key',
                    hint: 'e.g., XXX123',
                    icon: Icons.key,
                  ),
                  SizedBox(height: sh * 0.025),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.025),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.medium(context,
                                isTablet ? 15 : 14, AppColors.textSecondary),
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.025),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Store the main screen context BEFORE closing dialog
                            final mainScreenContext = this.context;

                            // Close dialog first
                            Navigator.of(context).pop();

                            setState(() {
                              _isCreateBackup = true;
                            });

                            await _provider.addAttendanceBackup(
                                name: nameController.text.trim(),
                                uniqueKey: keyController.text.trim(),
                                context: mainScreenContext);

                            setState(() {
                              _isCreateBackup = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.025),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,
                                  color: Colors.white,
                                  size: sw * (isTablet ? 0.045 : 0.048)),
                              SizedBox(width: sw * 0.015),
                              Text(
                                'Create',
                                style: AppTextStyles.medium(
                                    context, isTablet ? 15 : 14, Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRestoreBackupDialog(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    final nameController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.06 : 0.065)),
        ),
        child: Container(
          width: sw * 0.85,
          padding: EdgeInsets.all(sw * (isTablet ? 0.05 : 0.055)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * (isTablet ? 0.025 : 0.028)),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                            sw * (isTablet ? 0.035 : 0.038)),
                      ),
                      child: Icon(
                        Icons.cloud_download_outlined,
                        color: AppColors.success,
                        size: sw * (isTablet ? 0.055 : 0.058),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: Text(
                        'Restore Data',
                        style: AppTextStyles.bold(
                            context, isTablet ? 18 : 16, AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.03),
                _buildModernTextField(
                  context,
                  sw,
                  sh,
                  isTablet,
                  controller: nameController,
                  label: 'Your Name',
                  hint: 'Enter the name used for backup',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: sh * 0.02),
                _buildModernTextField(
                  context,
                  sw,
                  sh,
                  isTablet,
                  controller: keyController,
                  label: 'Your Unique Key',
                  hint: 'Paste your unique key here',
                  icon: Icons.vpn_key_outlined,
                ),
                SizedBox(height: sh * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.025),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.medium(context,
                              isTablet ? 15 : 14, AppColors.textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Store the main screen context BEFORE closing dialog
                          final mainScreenContext = this.context;

                          // Close dialog first
                          Navigator.of(context).pop();

                          setState(() {
                            _isRestoreBackup = true;
                          });

                          await _provider.getAttendanceRecord(
                              context: mainScreenContext,
                              name: nameController.text.trim(),
                              uniqueKey: keyController.text.trim());

                          setState(() {
                            _isRestoreBackup = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.025),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check,
                                color: Colors.white,
                                size: sw * (isTablet ? 0.045 : 0.048)),
                            SizedBox(width: sw * 0.015),
                            Text(
                              'Restore',
                              style: AppTextStyles.medium(
                                  context, isTablet ? 15 : 14, Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    final nameController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.06 : 0.065)),
        ),
        child: Container(
          width: sw * 0.85,
          padding: EdgeInsets.all(sw * (isTablet ? 0.05 : 0.055)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * (isTablet ? 0.025 : 0.028)),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                            sw * (isTablet ? 0.035 : 0.038)),
                      ),
                      child: Icon(
                        Icons.delete_forever_outlined,
                        color: AppColors.accent,
                        size: sw * (isTablet ? 0.055 : 0.058),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: AppTextStyles.bold(
                            context, isTablet ? 18 : 16, AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.015),
                Text(
                  'This action is permanent and cannot be undone. Please proceed with caution.',
                  style: AppTextStyles.regular(
                      context, isTablet ? 14 : 12, AppColors.accent),
                ),
                SizedBox(height: sh * 0.025),
                _buildModernTextField(
                  context,
                  sw,
                  sh,
                  isTablet,
                  controller: nameController,
                  label: 'Your Name',
                  hint: 'Confirm your name',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: sh * 0.02),
                _buildModernTextField(
                  context,
                  sw,
                  sh,
                  isTablet,
                  controller: keyController,
                  label: 'Your Unique Key',
                  hint: 'Confirm your unique key',
                  icon: Icons.vpn_key_outlined,
                ),
                SizedBox(height: sh * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.025),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.medium(context,
                              isTablet ? 15 : 14, AppColors.textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Store the main screen context BEFORE closing dialog
                          final mainScreenContext = this.context;

                          // Close dialog first
                          Navigator.of(context).pop();

                          setState(() {
                            _isDelete = true;
                          });

                          await _provider.deleteAttendanceBackup(
                              name: nameController.text.trim(),
                              uniqueKey: keyController.text.trim(),
                              context: mainScreenContext);

                          setState(() {
                            _isDelete = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.025),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: sw * (isTablet ? 0.045 : 0.048)),
                            SizedBox(width: sw * 0.015),
                            Text(
                              'Delete',
                              style: AppTextStyles.medium(
                                  context, isTablet ? 15 : 14, Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    BuildContext context,
    double sw,
    double sh,
    bool isTablet, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.medium(
              context, isTablet ? 15 : 14, AppColors.textPrimary),
        ),
        SizedBox(height: sh * 0.012),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.8),
            borderRadius:
                BorderRadius.circular(sw * (isTablet ? 0.035 : 0.038)),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: isTablet ? 14 : 13,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(sw * (isTablet ? 0.025 : 0.028)),
                padding: EdgeInsets.all(sw * (isTablet ? 0.018 : 0.02)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(sw * 0.018),
                ),
                child: Icon(icon,
                    color: AppColors.primary,
                    size: sw * (isTablet ? 0.045 : 0.048)),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: sh * (isTablet ? 0.02 : 0.022),
                  horizontal: sw * (isTablet ? 0.035 : 0.038)),
            ),
          ),
        ),
      ],
    );
  }
}
