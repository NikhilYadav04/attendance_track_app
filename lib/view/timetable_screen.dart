import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String? _timetableImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTimetableImage();
  }

  _loadTimetableImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('timetable_image_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _timetableImagePath = imagePath;
      });
    }
  }

  _saveTimetableImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('timetable_image_path', imagePath);
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final String fileName = 'timetable_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String localPath = '${appDir.path}/$fileName';
        
        await File(image.path).copy(localPath);
        
        setState(() {
          _timetableImagePath = localPath;
        });
        
        await _saveTimetableImage(localPath);
        
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timetable image added successfully! 📅'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add timetable image'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

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
          'My Timetable',
          style: AppTextStyles.bold(
            context,
            isTablet ? 22 : 18,
            Colors.white,
          ),
        ),
      ),
      body: _timetableImagePath == null
          ? _buildEmptyState(context, sw, sh, isTablet)
          : _buildTimetableView(context, sw, sh, isTablet),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickImage,
        backgroundColor: _isLoading ? Colors.grey : AppColors.secondary,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Icon(
                _timetableImagePath == null ? Icons.add_photo_alternate : Icons.edit,
                color: Colors.white,
                size: isTablet ? sw * 0.045 : sw * 0.065,
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double sw, double sh, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? sw * 0.25 : sw * 0.4,
              height: isTablet ? sw * 0.25 : sw * 0.4,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? sw * 0.06 : sw * 0.1),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: Icon(
                Icons.schedule,
                size: isTablet ? sw * 0.12 : sw * 0.2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: sh * 0.04),
            Text(
              'No Timetable Added Yet',
              style: AppTextStyles.bold(
                context,
                isTablet ? 28 : 24,
                AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sh * 0.015),
            Text(
              'Add your class timetable image to keep track of your schedule!',
              textAlign: TextAlign.center,
              style: AppTextStyles.regular(
                context,
                isTablet ? 18 : 16,
                AppColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.05),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(Icons.add_photo_alternate, color: Colors.white),
              label: Text(
                _isLoading ? 'Adding...' : 'Add Timetable Image',
                style: AppTextStyles.medium(context, isTablet ? 18 : 16, Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.06,
                  vertical: sh * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableView(BuildContext context, double sw, double sh, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.04),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: isTablet ? 24 : 20),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Text(
                    'Timetable Ready! 📅',
                    style: AppTextStyles.bold(
                      context,
                      isTablet ? 18 : 16,
                      AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sh * 0.025),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Row(
                      children: [
                        Icon(Icons.image, color: AppColors.primary, size: 24),
                        SizedBox(width: sw * 0.02),
                        Text(
                          'Your Timetable',
                          style: AppTextStyles.bold(
                            context,
                            isTablet ? 18 : 16,
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.file(
                    File(_timetableImagePath!),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: sh * 0.3,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                            SizedBox(height: 10),
                            Text('Failed to load image'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}