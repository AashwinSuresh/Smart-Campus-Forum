import 'package:campusapp/pages/community_page.dart';
import 'package:campusapp/pages/events_page.dart';
import 'package:campusapp/screens/lost_found_screen.dart';
import 'package:campusapp/widgets/custom_nav_bar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const CommunityPage(),
    const EventsPage(),
    const LostFoundScreen(),
    const Center(
      child: Text("Report page", style: TextStyle(color: Colors.white)),
    ),
  ];
  @override
  Widget build(BuildContext context) {
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
