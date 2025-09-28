

import 'dart:convert';
import 'dart:io';
import 'package:helawork_app/models/contract_model.dart';
import 'package:helawork_app/models/proposal.dart';
import 'package:http/http.dart' as http;

class ApiService{
  static const String baseUrl = 'http://192.168.100.188:8000';
  static const String registerUrl = '$baseUrl/apiregister';
  static const String  loginUrl ='$baseUrl/apilogin';
  static const String paymentsummaryUrl='$baseUrl/apipaymentsummary';
  static const String getuserprofileUrl = '$baseUrl/apigetprofile';
  static const String recentUrl = '$baseUrl/apirecent';
  static const String active_sessionUrl = '$baseUrl/apiactivesession';
  static const String earningUrl = '$baseUrl/apiearing';  
  static const String taskUrl = '$baseUrl/task';
  static const String  withdraw_mpesaUrl = '$baseUrl/mpesa';
  static const String  updateUserProfileUrl = '$baseUrl/apiuserprofile';
  

Future<Map<String, dynamic>> register(String name, String email,String phoneNO, String password,  String confirmPassword) async {
  final url = Uri.parse(registerUrl);
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone_number": phoneNO,
        "password": password,
        "confirmPassword": confirmPassword,
        
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true};
    } else {
      final responseData = jsonDecode(response.body);
      print("Backend response: $responseData");
      return {"success": false, "message": responseData["error"] ?? responseData.toString()};
    }
  } catch (e) {
    print("Registration error: $e");
    return {"success": false, "message": "Network error, please try again."};
  }
}

static Future<String> getLoggedInUserName() async {
  final response = await http.get(
    Uri.parse("$baseUrl/apiuserlogin"),
    headers: {
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // adjust this key depending on your backend response
    return data["username"] ?? data["name"] ?? "User";
  } else {
    return "User";
  }
}


Future<Map<String, dynamic>> login(String name, String password) async { 
  final url = Uri.parse(ApiService.loginUrl);

  print("Logging in with name: $name, password: $password");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "password": password}),
    );

    print("HTTP status: ${response.statusCode}");
    print("Raw response body: ${response.body}");

    
    Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      
      return {
        "success": false,
        "message": "Invalid response from server",
        "error": response.body,
      };
    }

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": responseData,
      };
    } else {
      return {
        "success": false,
        "message": responseData["error"] ?? "Invalid credentials",
        "error": responseData,
      };
    }
  } catch (e) {
    print("Login error: $e");
    return {
      "success": false,
      "message": "Network or server error: $e",
    };
  }
}

  Future<Map<String, dynamic>> getActiveSession() async {
    final response = await http.get(Uri.parse(active_sessionUrl));
    return json.decode(response.body);
  }
 Future<Map<String, dynamic>> getEarnings() async {
    final response = await http.get(Uri.parse(earningUrl));
    return json.decode(response.body);
  }

 
static Future<List<Map<String, dynamic>>> fetchTasks() async {
  final response = await http.get(Uri.parse(taskUrl));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    
    if (data.isEmpty) {
      return [
        {"id": 0, "title": "No tasks available"}
      ];
    }

    return data.map((task) => Map<String, dynamic>.from(task)).toList();
  } else {
    throw Exception("Failed to load tasks: ${response.statusCode}");
  }
}
Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profile) async {
  try {
    final Map<String, dynamic> profileData = Map.from(profile);
    
    // Convert File to base64 string if present
    if (profileData.containsKey('profile_picture') && profileData['profile_picture'] is File) {
      File file = profileData['profile_picture'];
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      profileData['profile_picture'] = base64Image;
    }
    
    final response = await http.post(
      Uri.parse(updateUserProfileUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(profileData),
    );

    if (response.statusCode == 200) {
      
      try {
        final userProfile = await ApiService.getUserProfile();
        // Update the dashboard provider with new profile data
        // You'll need to access the provider here or return the data
        return {
          "success": true,
          "message": "Profile updated successfully",
          "userData": userProfile, 
        };
      } catch (e) {
        
        return {
          "success": true,
          "message": "Profile updated successfully, but failed to refresh data: $e",
        };
      }
    } else {
      return {
        "success": false,
        "message": "Failed to update profile: ${response.statusCode}",
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Network error: $e",
    };
  }
}

 static Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(Uri.parse(getuserprofileUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user profile: ${response.statusCode}");
    }
  }

  
   
  static Future<Map<String, dynamic>> getPaymentSummary() async {
    final response = await http.get(Uri.parse(paymentsummaryUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load payment summary");
    }
  }

  // Withdraw payment via M-PESA
  static Future<Map<String, dynamic>> withdrawMpesa() async {
    final response = await http.get(Uri.parse(withdraw_mpesaUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to initiate withdrawal");
    }
  }

   static Future<List<dynamic>> getData(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint/');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  
  static Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            "Failed to post data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  


    static Future<Map<String, dynamic>> submitRating({
    required int taskId,
    required int raterId,
    required int ratedUserId,
    required int score,
    String? comment,
  }) async {
    final body = {
      "task": taskId,
      "rater": raterId,
      "rated_user": ratedUserId,
      "score": score,
      "comment": comment ?? "",
    };

    return await postData("ratings/", body);
  }


  /// Submit a new proposal
  static Future<Proposal> submitProposal(Proposal proposal, String proposalUrl) async {
    final url = Uri.parse(proposalUrl);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(proposal.toJson()),
      );

      if (response.statusCode == 201) {
        return Proposal.fromJson(json.decode(response.body));
      } else {
        throw Exception("Failed to submit proposal: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error submitting proposal: $e");
    }
  }

   Future<List<Contract>> fetchContracts() async {
    final url = Uri.parse("$baseUrl/contracts/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Contract.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load contracts: ${response.body}");
    }
  }

  
  Future<void> acceptContract(int contractId) async {
    final url = Uri.parse("$baseUrl/contracts/$contractId/accept/");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to accept contract: ${response.body}");
    }
  }

  
  Future<void> rejectContract(int contractId) async {
    final url = Uri.parse("$baseUrl/contracts/$contractId/reject/");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to reject contract: ${response.body}");
    }
  }
}


  