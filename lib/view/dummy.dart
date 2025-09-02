import 'package:attendance_tracker/provider/backup_provider.dart';
import 'package:flutter/material.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  final BackupProvider _backupProvider = BackupProvider();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              ElevatedButton(
                  onPressed: () {
                    /// _backupProvider.registerUser(context, name: "Nikhil");
                    // _backupProvider.addAttendanceBackup(
                    //     uniqueKey: "e286ea69d8f8", context: context);
                    // _backupProvider.getAttendanceRecord(
                    //     context: context,
                    //     name: "Nikhil",
                    //     uniqueKey: "e286ea69d8f8");
                    _backupProvider.sendEmail(
                        context: context,
                        email: "byadav1723@gmail.com",
                        uniqueKey: "123");
                  },
                  child: Center(
                    child: Text("Register User"),
                  )),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Center(
                    child: Text("Add Backup"),
                  )),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Center(
                    child: Text("get Backup"),
                  )),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Center(
                    child: Text("Delete User"),
                  )),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
