import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'secure_storage.dart';

class ApiService {
  // static const baseUrl = "";
  static const baseUrl = "http://127.0.0.1:5000";
  static String? token;

  // Get token from secure storage or static variable
  static Future<String?> _getToken() async {
    if (token != null) {
      return token;
    }
    // Try to retrieve from secure storage
    try {
      final storedToken = await SecureStorage.getToken();
      if (storedToken != null) {
        token = storedToken;
        return storedToken;
      }
    } catch (e) {
      print("Error retrieving token: $e");
    }
    return null;
  }

  // Public method to get token (for external use)
  static Future<String?> getToken() async {
    return await _getToken();
  }

  static Future<bool> login(String id, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "credential": id,  
          "name": id,        
          "password": password,
          "role": role,
        }),
      );

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
          token = responseData["access_token"];
          // persist token so other calls (and app restarts) can access it
          try {
            await SecureStorage.saveToken(token!);
          } catch (e) {
            print('[Login] Warning: failed to save token: $e');
          }
          print("[Login] Success - Token: $token");
        return true;
      } else {
        print("[Login] Failed - Status: ${res.statusCode}, Body: ${res.body}");
        return false;
      }
    } catch (e) {
      print("[Login] Error: $e");
      return false;
    }
  }

  static Future<bool> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<int?> directSOS() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return null;
      }

      print("DirectSOS - Token: $authToken");
      final res = await http.post(
        Uri.parse("$baseUrl/citizen/direct-sos"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json"
        },
        body: jsonEncode({}),
      );
      
      print("DirectSOS Response: ${res.statusCode} - ${res.body}");
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        final alertId = jsonDecode(res.body)["alert_id"];
        print("DirectSOS - Alert created with ID: $alertId");
        return alertId;
      }
      return null;
    } catch (e) {
      print("DirectSOS error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAmbulanceStatus(int alertId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return null;
      }

      final res = await http.get(
        Uri.parse("$baseUrl/citizen/ambulance-status/$alertId"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      
      print("GetAmbulanceStatus - Status: ${res.statusCode}, Body: ${res.body}");
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else if (res.statusCode == 401) {
        print("Unauthorized - Token may be expired");
        token = null; // Clear token on 401
        return null;
      } else {
        print("Error getting ambulance status: ${res.statusCode} - ${res.body}");
        return null;
      }
    } catch (e) {
      print("Exception in getAmbulanceStatus: $e");
      return null;
    }
  }

  static Future<List<dynamic>> getHospitalCases() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("GetHospitalCases: No token available");
        return [];
      }
      
      print("GetHospitalCases - Token: $token");
      final res = await http.get(
        Uri.parse("$baseUrl/hospital/cases"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print("GetHospitalCases: Request timeout after 30 seconds");
        throw TimeoutException("Hospital cases request timed out");
      });
      
      print("GetHospitalCases Response: ${res.statusCode} - ${res.body}");
      
      if (res.statusCode != 200) {
        print("GetHospitalCases error: ${res.statusCode} - ${res.body}");
        return [];
      }
      
      final data = jsonDecode(res.body);
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      print("GetHospitalCases error: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getAmbulanceCases() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("GetAmbulanceCases: No token available");
        return [];
      }

      print("GetAmbulanceCases - Token: $token");
      final res = await http.get(
        Uri.parse("$baseUrl/ambulance/dashboard"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("GetAmbulanceCases - Status: ${res.statusCode}, Body: ${res.body}");

      if (res.statusCode != 200) {
        print("GetAmbulanceCases error: ${res.statusCode}");
        return [];
      }

      final data = jsonDecode(res.body);
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      print("GetAmbulanceCases error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> checkSeverity(String symptoms) async {
    try {
      print("CheckSeverity - Token: $token");
      final res = await http.post(
        Uri.parse("$baseUrl/citizen/check-severity"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"symptoms": symptoms}),
      );
      print("CheckSeverity Response: ${res.statusCode} - ${res.body}");
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {};
    } catch (e) {
      print("CheckSeverity error: $e");
      return {};
    }
  }

  static Future<List<dynamic>> getHospitals() async {
    try {
      print("GetHospitals - Token: $token");
      final res = await http.get(
        Uri.parse("$baseUrl/citizen/get-hospitals"),
        headers: {"Authorization": "Bearer $token"},
      );
      
      print("GetHospitals Response: ${res.statusCode} - ${res.body}");
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          return data;
        }
        return [];
      }
      print("GetHospitals failed: ${res.body}");
      return [];
    } catch (e) {
      print("GetHospitals error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitSymptoms(String symptoms) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("SubmitSymptoms: No token available");
        throw Exception("Authentication token not found");
      }

      print("SubmitSymptoms - Token: $token");
      print("SubmitSymptoms - Symptoms: $symptoms");

      final response = await http.post(
        Uri.parse('$baseUrl/symptoms/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'symptoms': symptoms}),
      );

      print("SubmitSymptoms Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      }

      // Try to get error message from response
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to submit symptoms');
      } catch (_) {
        throw Exception('Failed to submit symptoms (${response.statusCode})');
      }
    } catch (e) {
      print("SubmitSymptoms error: $e");
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getGovernmentAnalytics() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) return {};

      final response = await http.get(
        Uri.parse("$baseUrl/government/analytics"),
        headers: {"Authorization": "Bearer $authToken"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Hospital Profile Management
  static Future<Map<String, dynamic>?> getHospitalProfile() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/hospital/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateHospitalProfile(Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/hospital/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Citizen Profile Management
  static Future<Map<String, dynamic>?> getCitizenProfile() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/citizen/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateCitizenProfile(Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/citizen/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> completeAlert(int alertId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return false;
      }

      final res = await http.put(
        Uri.parse("$baseUrl/citizen/alerts/$alertId/complete"),
        headers: {"Authorization": "Bearer $authToken"},
      );

      print("CompleteAlert - Status: ${res.statusCode}, Body: ${res.body}");

      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Exception in completeAlert: $e");
      return false;
    }
  }

  static Future<bool> updateAmbulanceLocation(double latitude, double longitude) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return false;
      }

      final res = await http.post(
        Uri.parse("$baseUrl/ambulance/location"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      print("UpdateAmbulanceLocation - Status: ${res.statusCode}, Lat: $latitude, Lon: $longitude");

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Exception in updateAmbulanceLocation: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getAmbulanceLocation(int alertId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return null;
      }

      final res = await http.get(
        Uri.parse("$baseUrl/ambulance/location/$alertId"),
        headers: {"Authorization": "Bearer $authToken"},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print("Exception in getAmbulanceLocation: $e");
      return null;
    }
  }

  static Future<bool> updateCitizenLocation(double latitude, double longitude) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return false;
      }

      final res = await http.post(
        Uri.parse("$baseUrl/citizen/location"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      print("UpdateCitizenLocation - Status: ${res.statusCode}, Lat: $latitude, Lon: $longitude");

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Exception in updateCitizenLocation: $e");
      return false;
    }
  }

  static Future<bool> verifyUserExists(String identifier, String role) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/verify-user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "credential": identifier,
          "role": role,
        }),
      );

      print("VerifyUser - Status: ${res.statusCode}");
      return res.statusCode == 200;
    } catch (e) {
      print("Exception in verifyUserExists: $e");
      return false;
    }
  }

  static Future<bool> resetPassword(String identifier, String newPassword, String role) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "credential": identifier,
          "new_password": newPassword,
          "role": role,
        }),
      );

      print("ResetPassword - Status: ${res.statusCode}");
      return res.statusCode == 200;
    } catch (e) {
      print("Exception in resetPassword: $e");
      return false;
    }
  }

  // ===== DYNAMIC HOSPITAL RANKING =====
  static Future<Map<String, dynamic>> getDynamicHospitals(int severityId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print("Error: No authentication token available");
        return {"hospitals": [], "error": "No token"};
      }

      final res = await http.get(
        Uri.parse("$baseUrl/citizen/hospitals-by-severity/$severityId"),
        headers: {"Authorization": "Bearer $authToken"},
      );

      print("GetDynamicHospitals - Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        print("Error: ${res.body}");
        return {"hospitals": [], "error": "Failed to fetch hospitals"};
      }
    } catch (e) {
      print("Exception in getDynamicHospitals: $e");
      return {"hospitals": [], "error": e.toString()};
    }
  }
}