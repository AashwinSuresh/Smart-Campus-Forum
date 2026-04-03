import 'package:campusapp/pages/backup_lost_found/backup_lost_found_list_page.dart';
import 'package:campusapp/pages/community_page.dart';
import 'package:campusapp/pages/events_page.dart';
import 'package:campusapp/pages/harassment/my_reports_page.dart';
import 'package:campusapp/pages/admin_panel_page.dart';
import 'package:campusapp/pages/harassment/harassment_monitor_page.dart'; // We will create this next
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/widgets/custom_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  bool _isRoleLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      final fcm = FirebaseMessaging.instance;
      
      // Get the token for this device
      String? token = await fcm.getToken();
      if (token != null) {
        await ApiService.registerFCMToken(token);
      }

      // Handle token refreshes
      fcm.onTokenRefresh.listen((newToken) {
        ApiService.registerFCMToken(newToken);
      });

      // Handle foreground notifications (optional alert)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received Foreground Message: ${message.notification?.title}");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text("${message.notification?.title}: ${message.notification?.body}"),
               backgroundColor: Colors.orangeAccent,
             ),
           );
        }
      });
    } catch (e) {
      print("FCM Init Error: $e");
    }
  }

  Future<void> _checkUserRole() async {
    await ApiService.fetchRole();
    if (mounted) {
      setState(() {
        _isRoleLoading = false;
      });
    }
  }

  List<Widget> get _pages {
    final role = ApiService.currentUserRole;
    
    return [
      const CommunityPage(),
      const EventsPage(),
      const BackupLostFoundListPage(),
      if (role == 'admin')
        const AdminPanelPage()
      else if (role == 'staff')
        const HarassmentMonitorPage()
      else
        const MyReportsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isRoleLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    // DEBUG: Confirm role in Dashboard build
    print("DASHBOARD BUILD: Current Role is ${ApiService.currentUserRole}");
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomAiamtedNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
