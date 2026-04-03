import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campusapp/models/harassment_report.dart';
import 'package:campusapp/services/api_service.dart'; // To reuse ApiService.baseUrl
import 'package:supabase_flutter/supabase_flutter.dart';

class HarassmentService {
  // Make this a getter so it doesn't evaluate eagerly and crash if uninitialized
  static SupabaseClient get supabase => Supabase.instance.client;

  /// Fetch all harassment reports for the current user (Student view)
  static Future<List<HarassmentReport>> fetchReports() async {
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return [];
      }

      final url = '${ApiService.baseUrl}/harassment-reports?user_id=$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['reports'];
        return data.map((json) => HarassmentReport.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  /// [STAFF ONLY] Fetch all harassment reports in the database
  static Future<List<HarassmentReport>> fetchAllReports() async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      final url = '${ApiService.baseUrl}/harassment-reports/all';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['reports'];
        return data.map((json) => HarassmentReport.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching all reports: $e');
      return [];
    }
  }

  /// Create a new harassment report
  static Future<bool> createReport({
    required String title,
    required String description,
    required DateTime incidentDate,
    required String location,
  }) async {
    final url = '${ApiService.baseUrl}/harassment-reports';
    
    try {
      final token = supabase.auth.currentSession?.accessToken;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return false;

      final body = {
        'title': title,
        'description': description,
        'incident_date': "${incidentDate.year}-${incidentDate.month.toString().padLeft(2, '0')}-${incidentDate.day.toString().padLeft(2, '0')}",
        'location': location,
        'reporter_id': userId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating report: $e');
      return false;
    }
  }

  /// [STAFF ONLY] Update the status of a report
  static Future<bool> updateReportStatus(String reportId, String newStatus) async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      final url = '${ApiService.baseUrl}/harassment-reports/$reportId/status';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  /// Cancel a pending report manually (Student)
  static Future<bool> cancelReport(String reportId) async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return false;

      final url = '${ApiService.baseUrl}/harassment-reports/$reportId/cancel?user_id=$userId';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling report: $e');
      return false;
    }
  }
}
