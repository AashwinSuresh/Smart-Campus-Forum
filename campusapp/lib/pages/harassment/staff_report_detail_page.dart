import 'package:flutter/material.dart';
import 'package:campusapp/models/harassment_report.dart';
import 'package:campusapp/services/harassment_service.dart';
import 'package:campusapp/services/pdf_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffReportDetailPage extends StatefulWidget {
  final HarassmentReport report;
  const StaffReportDetailPage({super.key, required this.report});

  @override
  State<StaffReportDetailPage> createState() => _StaffReportDetailPageState();
}

class _StaffReportDetailPageState extends State<StaffReportDetailPage> {
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final success = await HarassmentService.updateReportStatus(widget.report.id, newStatus);
    setState(() => _isUpdating = false);

    if (success) {
      setState(() => _currentStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${newStatus.toUpperCase()}')),
      );
    }
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
    final report = widget.report;
    final dateStr = DateFormat('dd MMM yyyy').format(report.incidentDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Incident Detail', style: GoogleFonts.oswald()),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => PdfService.generateAndPrintReport(report),
            tooltip: 'Export to PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(_currentStatus)),
              ),
              child: Text(
                _currentStatus.toUpperCase(),
                style: TextStyle(color: _getStatusColor(_currentStatus), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // Reporter Info Card
            _sectionTitle('REPORTER INFORMATION'),
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white10,
                      backgroundImage: report.reporterPic != null ? NetworkImage(report.reporterPic!) : null,
                      child: report.reporterPic == null ? const Icon(Icons.person, color: Colors.white54) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.reporterName ?? 'Unknown Student', 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(report.reporterDept ?? 'No Department Info', 
                            style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          Text('ID: ${report.reporterId}', 
                             style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            _sectionTitle('INCIDENT DETAILS'),
            _detailRow(Icons.title, 'TITLE', report.title),
            _detailRow(Icons.calendar_today_outlined, 'DATE', dateStr),
            _detailRow(Icons.location_on_outlined, 'LOCATION', report.location),
            
            const SizedBox(height: 24),
            _sectionTitle('DESCRIPTION'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                report.description,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 40),
            _sectionTitle('TAKE ACTION'),
            const SizedBox(height: 12),
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                   _actionButton('Under Review', Colors.blue, 'under_review'),
                   const SizedBox(width: 10),
                   _actionButton('Resolved', Colors.green, 'resolved'),
                ],
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.oswald(textStyle: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.2)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, String statusValue) {
    bool isCurrent = _currentStatus == statusValue;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrent ? color : Colors.transparent,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: isCurrent ? null : () => _updateStatus(statusValue),
        child: Text(
          label,
          style: TextStyle(color: isCurrent ? Colors.white : color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
