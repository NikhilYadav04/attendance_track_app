import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For ResponsiveHelper and AppTextStyles

class BackupScreen extends StatefulWidget {
  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  // --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: isTablet ? sh * 0.1 : sh * 0.08,
        title: Text(
          'Backup & Restore',
          style: AppTextStyles.bold(
            context,
            isTablet ? 22 : 18,
            Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () async {
              // Debugging or info functionality can be placed here
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? userData = prefs.getString('user_data');
              Logger().d(userData);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.05,
          vertical: sh * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Added proper title section
            Text(
              'Data Management',
              style: AppTextStyles.bold(
                  context, isTablet ? 28 : 24, AppColors.textPrimary),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'Secure your attendance data with backup and restore options',
              style: AppTextStyles.regular(
                  context, isTablet ? 16 : 14, AppColors.textSecondary),
            ),
            SizedBox(height: sh * 0.04),

            // Improved option cards
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
            SizedBox(height: sh * 0.02),
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
            SizedBox(height: sh * 0.02),
            // START: New Delete Account Card
            _buildOptionCard(
              context,
              sw,
              sh,
              isTablet,
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle:
                  'Permanently delete your account and all associated data from our servers.',
              color: AppColors.accent, // Using accent color for destructive action
              onTap: () => _showDeleteAccountDialog(context),
            ),
            // END: New Delete Account Card
          ],
        ),
      ),
    );
  }

  // Enhanced option card with better styling and proper responsive scaling
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
        padding: EdgeInsets.all(sw * (isTablet ? 0.04 : 0.045)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.06 : 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: sw * 0.05,
              offset: Offset(0, sh * 0.01),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: sw * 0.01,
              offset: Offset(0, sh * 0.003),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: sw * (isTablet ? 0.15 : 0.16),
              height: sw * (isTablet ? 0.15 : 0.16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(sw * (isTablet ? 0.04 : 0.035)),
              ),
              child:
                  Icon(icon, color: color, size: sw * (isTablet ? 0.08 : 0.07)),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bold(
                        context, isTablet ? 20 : 18, AppColors.textPrimary),
                  ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    subtitle,
                    style: AppTextStyles.regular(
                        context, isTablet ? 15 : 13, AppColors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.02),
            Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(sw * 0.03),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary.withOpacity(0.6),
                size: sw * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---

  void _showCreateBackupDialog(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final keyController = TextEditingController();
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
                    BorderRadius.circular(sw * (isTablet ? 0.07 : 0.075)),
              ),
              child: Container(
                width: sw * 0.9,
                padding: EdgeInsets.all(sw * (isTablet ? 0.06 : 0.065)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon and title
                      Row(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.all(sw * (isTablet ? 0.03 : 0.032)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  sw * (isTablet ? 0.04 : 0.042)),
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                              size: sw * (isTablet ? 0.06 : 0.065),
                            ),
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Text(
                              'Create New Backup',
                              style: AppTextStyles.bold(context,
                                  isTablet ? 20 : 18, AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.04),

                      // Name field
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
                      SizedBox(height: sh * 0.025),

                      // Unique Key Display
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
                      SizedBox(height: sh * 0.015),

                      // Email checkbox
                      Container(
                        padding: EdgeInsets.all(sw * 0.01),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: isTablet ? 1.2 : 1.0,
                              child: Checkbox(
                                value: sendEmail,
                                onChanged: (bool? value) => setDialogState(
                                    () => sendEmail = value ?? false),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.01),
                                ),
                              ),
                            ),
                            SizedBox(width: sw * 0.02),
                            Expanded(
                              child: Text(
                                "Send key to my email",
                                style: AppTextStyles.regular(context,
                                    isTablet ? 16 : 15, AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (sendEmail) ...[
                        SizedBox(height: sh * 0.02),
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

                      SizedBox(height: sh * 0.02),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    EdgeInsets.symmetric(vertical: sh * 0.02),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.03),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.medium(
                                    context,
                                    isTablet ? 16 : 15,
                                    AppColors.textSecondary),
                              ),
                            ),
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    EdgeInsets.symmetric(vertical: sh * 0.02),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.03),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white,
                                      size: sw * (isTablet ? 0.05 : 0.055)),
                                  SizedBox(width: sw * 0.02),
                                  Text(
                                    'Create',
                                    style: AppTextStyles.medium(context,
                                        isTablet ? 16 : 15, Colors.white),
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

  void _showRestoreBackupDialog(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    final nameController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.07 : 0.075)),
        ),
        child: Container(
          width: sw * 0.9,
          padding: EdgeInsets.all(sw * (isTablet ? 0.06 : 0.065)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * (isTablet ? 0.03 : 0.032)),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                            sw * (isTablet ? 0.04 : 0.042)),
                      ),
                      child: Icon(
                        Icons.cloud_download_outlined,
                        color: AppColors.success,
                        size: sw * (isTablet ? 0.06 : 0.065),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Text(
                        'Restore Data',
                        style: AppTextStyles.bold(
                            context, isTablet ? 20 : 18, AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.04),

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
                SizedBox(height: sh * 0.025),
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
                SizedBox(height: sh * 0.04),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.medium(context,
                              isTablet ? 16 : 15, AppColors.textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check,
                                color: Colors.white,
                                size: sw * (isTablet ? 0.05 : 0.055)),
                            SizedBox(width: sw * 0.02),
                            Text(
                              'Restore',
                              style: AppTextStyles.medium(
                                  context, isTablet ? 16 : 15, Colors.white),
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

  // START: New Delete Account Dialog
  void _showDeleteAccountDialog(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    final nameController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.07 : 0.075)),
        ),
        child: Container(
          width: sw * 0.9,
          padding: EdgeInsets.all(sw * (isTablet ? 0.06 : 0.065)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * (isTablet ? 0.03 : 0.032)),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                            sw * (isTablet ? 0.04 : 0.042)),
                      ),
                      child: Icon(
                        Icons.delete_forever_outlined,
                        color: AppColors.accent,
                        size: sw * (isTablet ? 0.06 : 0.065),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: AppTextStyles.bold(
                            context, isTablet ? 20 : 18, AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.02),
                Text(
                  'This action is permanent and cannot be undone. Please proceed with caution.',
                  style: AppTextStyles.regular(
                      context, isTablet ? 15 : 13, AppColors.accent),
                ),
                SizedBox(height: sh * 0.03),

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
                SizedBox(height: sh * 0.025),
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
                SizedBox(height: sh * 0.04),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.medium(context,
                              isTablet ? 16 : 15, AppColors.textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: sw * (isTablet ? 0.05 : 0.055)),
                            SizedBox(width: sw * 0.02),
                            Text(
                              'Delete',
                              style: AppTextStyles.medium(
                                  context, isTablet ? 16 : 15, Colors.white),
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
  // END: New Delete Account Dialog

  // Modern text field matching the design from image with responsive scaling
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
              context, isTablet ? 16 : 15, AppColors.textPrimary),
        ),
        SizedBox(height: sh * 0.015),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.8),
            borderRadius: BorderRadius.circular(sw * (isTablet ? 0.04 : 0.042)),
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
                fontSize: isTablet ? 15 : 14,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(sw * (isTablet ? 0.03 : 0.032)),
                padding: EdgeInsets.all(sw * (isTablet ? 0.02 : 0.022)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Icon(icon,
                    color: AppColors.primary,
                    size: sw * (isTablet ? 0.05 : 0.055)),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: sh * (isTablet ? 0.022 : 0.025),
                  horizontal: sw * (isTablet ? 0.04 : 0.042)),
            ),
          ),
        ),
      ],
    );
  }
}