import 'package:attendance_tracker/http/utils/http_client.dart';
import 'package:attendance_tracker/provider/backup_provider.dart';
import 'package:attendance_tracker/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  //* Initialize Http CLient
  await HttpClient().init();

  runApp(AttendanceTrackerApp());
}

class AttendanceTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BackupProvider())
      ],
      child: MaterialApp(
        title: 'Attendance Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getFontSize(BuildContext context, double baseSize) {
    double sw = getWidth(context);
    if (sw >= 600) return baseSize * 1.2; // Tablet
    return baseSize;
  }

  static double getSpacing(BuildContext context, double baseSpacing) {
    double sw = getWidth(context);
    if (sw >= 600) return baseSpacing * 1.5; // Tablet
    return baseSpacing;
  }

  static EdgeInsets getPadding(BuildContext context, double basePadding) {
    double sw = getWidth(context);
    if (sw >= 600) {
      return EdgeInsets.all(basePadding * 1.5);
    }
    return EdgeInsets.all(basePadding);
  }
}
