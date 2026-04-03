import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/models/backup_lost_found_item.dart';
import 'package:campusapp/services/backup_api_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackupItemDetailPage extends StatefulWidget {
  final BackupLostFoundItem item;

  const BackupItemDetailPage({super.key, required this.item});

  @override
  State<BackupItemDetailPage> createState() => _BackupItemDetailPageState();
}

class _BackupItemDetailPageState extends State<BackupItemDetailPage> {
  bool _isLoading = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.item.status;
  }

  Future<void> _closeCase() async {
    setState(() => _isLoading = true);
    try {
      await BackupApiService.closeBackupItem(widget.item.id);
      if (mounted) {
        setState(() {
          _currentStatus = 'closed';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case successfully closed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error closing item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.item.type == 'lost';
    final isClosed = _currentStatus == 'closed';
    
    // Check if current user is the one who posted it
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = currentUserId == widget.item.userId && currentUserId != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Item Details', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLost ? Colors.red[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLost ? 'LOST' : 'FOUND',
                          style: TextStyle(
                            color: isLost ? Colors.red[800] : Colors.green[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Case Closed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _closeCase,
                          child: Text(
                            isLost ? 'Mark as Found' : 'Mark as Claimed/Closed',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.item.imageUrl != null) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              backgroundColor: Colors.black,
                              appBar: AppBar(
                                backgroundColor: Colors.black,
                                iconTheme: const IconThemeData(color: Colors.white),
                              ),
                              body: Center(
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  child: Image.network(widget.item.imageUrl!),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(widget.item.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.white30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Item Name',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.itemName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reported By',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.reporterName ?? 
                        'User (ID: ${widget.item.userId.substring(0, 8)}...)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Location',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Date Reported',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.tealAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.createdAt.toLocal().toString().split('.')[0],
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 30, 30, 30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Phone Number',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SelectableText(
                                widget.item.phoneNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '(Long press the number to copy/dial)',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
