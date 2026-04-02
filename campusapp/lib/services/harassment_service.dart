import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campusapp/models/harassment_report.dart';
import 'package:campusapp/services/api_service.dart'; // To reuse ApiService.baseUrl
import 'package:supabase_flutter/supabase_flutter.dart';

class HarassmentService {
  // Make this a getter so it doesn't evaluate eagerly and crash if uninitialized
  static SupabaseClient get supabase => Supabase.instance.client;

  /// Fetch all harassment reports for the current user
  static Future<List<HarassmentReport>> fetchReports() async {
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return [];
      }

      final url = '${ApiService.baseUrl}/harassment-reports?user_id=$userId';
      // The session and token are correctly extracted above.

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
      print('Failed to fetch reports: ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching reports: $e');
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
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        print('User not logged in');
        return false;
      }

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      print('Failed to create report: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Error creating report: $e');
      return false;
    }
  }

  /// Cancel a pending report manually
  static Future<bool> cancelReport(String reportId) async {
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return false;
      }

      final url = '${ApiService.baseUrl}/harassment-reports/$reportId/cancel?user_id=$userId';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Failed to cancel report: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Error cancelling report: $e');
      return false;
    }
  }
}
