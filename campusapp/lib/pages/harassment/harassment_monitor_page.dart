import 'package:flutter/material.dart';
import 'package:campusapp/models/harassment_report.dart';
import 'package:campusapp/services/harassment_service.dart';
import 'package:campusapp/pages/harassment/staff_report_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HarassmentMonitorPage extends StatefulWidget {
  const HarassmentMonitorPage({super.key});

  @override
  State<HarassmentMonitorPage> createState() => _HarassmentMonitorPageState();
}

class _HarassmentMonitorPageState extends State<HarassmentMonitorPage> {
  late Future<List<HarassmentReport>> _reportsFuture;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = HarassmentService.fetchAllReports();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'under_review': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'INCIDENT MONITOR',
          style: GoogleFonts.oswald(textStyle: const TextStyle(fontSize: 24, letterSpacing: 1.5)),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterRow(),
          
          Expanded(
            child: FutureBuilder<List<HarassmentReport>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading reports', style: TextStyle(color: Colors.white54)));
                }

                final allReports = snapshot.data ?? [];
                final filteredReports = _filterStatus == null 
                  ? allReports 
                  : allReports.where((r) => r.status.toLowerCase() == _filterStatus).toList();

                if (filteredReports.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadReports(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _filterChip(null, "All"),
          _filterChip("pending", "Pending"),
          _filterChip("under_review", "Under Review"),
          _filterChip("resolved", "Resolved"),
        ],
      ),
    );
  }

  Widget _filterChip(String? status, String label) {
    bool isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: Colors.grey[900],
        selectedColor: Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12),
        onSelected: (val) {
          setState(() => _filterStatus = val ? status : null);
        },
      ),
    );
  }

  Widget _buildReportCard(HarassmentReport report) {
    final timeStr = DateFormat('dd MMM').format(report.createdAt);
    
    return Card(
      color: Colors.grey[900]?.withOpacity(0.5),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white10,
          backgroundImage: report.reporterPic != null ? NetworkImage(report.reporterPic!) : null,
          child: report.reporterPic == null ? const Icon(Icons.person, color: Colors.white54) : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                report.reporterName ?? 'Unknown',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getStatusColor(report.status), width: 0.5),
              ),
              child: Text(
                report.status.toUpperCase(),
                style: TextStyle(color: _getStatusColor(report.status), fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(report.reporterDept ?? 'Student', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Text(report.title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeStr, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StaffReportDetailPage(report: report)),
          );
          _loadReports(); // Refresh after coming back
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 60, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "No reports found in this category.",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
