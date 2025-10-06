

import 'package:http_parser/http_parser.dart';

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:helawork_app/models/contract_model.dart';
import 'package:helawork_app/models/proposal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String ProposalUrl = '$baseUrl/apiproposal';
  static const String proposalsUrl = '$baseUrl/apiproposal';

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
      // ✅ ✅ ✅ SAVE THE TOKEN TO SHARED PREFERENCES ✅ ✅ ✅
      final String? token = responseData["token"];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token); // Save with consistent key
        print('✅ TOKEN SAVED TO SHARED PREFERENCES: ${token.substring(0, 10)}...');
      }

      return {
        "success": true,
        "data": {
          "user_id": responseData["user_id"],
          "name": responseData["name"],
          "message": responseData["message"],
          "token": token,
        }
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
  try {
    
    final response = await http.get(Uri.parse('$baseUrl/task')); 
    
    print('Task API Response Status: ${response.statusCode}');
    print('Task API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      
      
      if (data is List) {
        if (data.isEmpty) {
          return [
            {
              "task_id": 0, 
              "title": "No tasks available",
              "description": "Check back later for new tasks",
              "employer": {"username": "System"}
            }
          ];
        }
        
        
        return data.map((task) {
          final mappedTask = Map<String, dynamic>.from(task);
          
          // Ensure all required fields exist
          mappedTask['completed'] = mappedTask['completed'] ?? false;
          mappedTask['employer'] = mappedTask['employer'] ?? {
            'username': 'Unknown Client',
            'company_name': 'Unknown Company'
          };
          
          return mappedTask;
        }).toList();
        
      } else if (data is Map && data.containsKey('error')) {
        throw Exception("API Error: ${data['error']}");
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception("Failed to load tasks: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print('Error fetching tasks: $e');
    rethrow;
  }
}

 Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profile, String token, String userId) async {
  try {
    final String url = "$baseUrl/apiuserprofile";

    var request = http.MultipartRequest("PUT", Uri.parse(url));

    
    request.headers.addAll({
      'Authorization': 'Bearer $token', 
      // 'Authorization': 'Token $token', 
      // 'Authorization': 'JWT $token', 
      'Accept': 'application/json',
    });

    
    request.fields['user_id'] = userId;

    
    profile.forEach((key, value) {
      if (value != null && value is! File) {
        request.fields[key] = value.toString();
      }
    });

    
    if (profile['profile_picture'] != null && profile['profile_picture'] is File) {
      File file = profile['profile_picture'];
      request.files.add(
          await http.MultipartFile.fromPath('profile_picture', file.path));
    }

    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

   
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "message": "Profile updated successfully",
        "data": json.decode(response.body),
      };
    } else if (response.statusCode == 401) {
      return {"success": false, "message": "Unauthorized. Please log in again."};
    } else {
      return {
        "success": false,
        "message": "Failed: ${response.statusCode} ${response.body}"
      };
    }
  } catch (e) {
    return {"success": false, "message": "Network error: $e"};
  }
}

static Future<String?> _getUserToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Check what keys actually exist
    final allKeys = prefs.getKeys();
    print('🔐 ALL SHARED PREFERENCES KEYS: $allKeys');
    
    // Try different possible keys
    String? token = prefs.getString('user_token');
    
    if (token == null) {
      // Try other common key names
      token = prefs.getString('token');
      print('🔐 Trying "token" key: ${token != null}');
    }
    
    if (token == null) {
      token = prefs.getString('auth_token');
      print('🔐 Trying "auth_token" key: ${token != null}');
    }
    
    if (token == null) {
      token = prefs.getString('access_token');
      print('🔐 Trying "access_token" key: ${token != null}');
    }

    if (token == null) {
      print('❌ NO TOKEN FOUND IN ANY KEY');
      print('   Available keys: $allKeys');
      print('   All key-value pairs:');
      for (String key in allKeys) {
        final value = prefs.get(key);
        print('     - $key: $value');
      }
      return null;
    }
    
    print('✅ TOKEN FOUND: ${token.substring(0, 10)}...');
    return token;
  } catch (e) {
    print('❌ ERROR RETRIEVING TOKEN: $e');
    return null;
  }
}
 
static Future<Map<String, dynamic>?> getUserProfile() async {
  try {
    
    final String? token = await _getUserToken();
    
    if (token == null) {
      print(' No authentication token found - user may not be logged in');
      return null;
    }

    print(' Fetching user profile with token: ${token.substring(0, 10)}...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/apiuserprofile'),
      headers: {
        'Authorization': 'Bearer $token', 
        'Accept': 'application/json',
      },
    );

    print('📡 Profile API Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(' User profile loaded successfully');
      print(' Profile data: $data');
      return Map<String, dynamic>.from(data);
    } else if (response.statusCode == 401) {
      print(' Unauthorized (401) - Token may be invalid or expired');
      print(' Response body: ${response.body}');
      return null;
    } else {
      print(' Failed to load user profile: ${response.statusCode}');
      print(' Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    print(' Network error loading user profile: $e');
    return null;
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
  static Future<Proposal> submitProposal(Proposal proposal, {PlatformFile? pdfFile}) async {
  try {
    // Get authentication token
    final String? token = await _getUserToken();
    
    if (token == null) {
      throw Exception("User not authenticated. Please log in again.");
    }

    
    if (pdfFile == null) {
      throw Exception("Cover letter PDF file is required");
    }

   
    if (pdfFile.bytes == null) {
      throw Exception("PDF file bytes are null - file may be corrupted");
    }

    print(' Starting proposal submission with PDF cover letter...');
    print(' PDF File: ${pdfFile.name} (${pdfFile.size} bytes)');
    print(' Proposal URL: $ProposalUrl');

    
    var request = http.MultipartRequest('POST', Uri.parse(ProposalUrl));
    
   
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
   
    // Add proposal data as fields
    request.fields['task_id'] = proposal.taskId.toString();
    request.fields['freelancer_id'] = proposal.freelancerId.toString();
    request.fields['bid_amount'] = proposal.bidAmount.toString();
    request.fields['status'] = proposal.status;
    
    
    if (proposal.title != null && proposal.title!.isNotEmpty) {
      request.fields['title'] = proposal.title!;
    } else {
      request.fields['title'] = 'Proposal for Task ${proposal.taskId}';
    }

    
    request.files.add(http.MultipartFile.fromBytes(
      'cover_letter_file',
      pdfFile.bytes!, // Now safe because we checked above
      filename: pdfFile.name,
      contentType: MediaType('application', 'pdf'),
    ));

    print(' Request prepared with fields:');
    print('   - task_id: ${proposal.taskId}');
    print('   - freelancer_id: ${proposal.freelancerId}');
    print('   - bid_amount: ${proposal.bidAmount}');
    print('   - status: ${proposal.status}');
    print('   - title: ${proposal.title}');
    print('   - file_field: cover_letter_file');
    print('   - file_name: ${pdfFile.name}');

    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    print(' Proposal API Response:');
    print('   - Status: ${response.statusCode}');
    print('   - Body: $responseBody');

    if (response.statusCode == 201 || response.statusCode == 200) {
      print(' Proposal submitted successfully!');
      final responseData = json.decode(responseBody);
      return Proposal.fromJson(responseData);
    } else if (response.statusCode == 401) {
      throw Exception("Authentication failed. Please log in again.");
    } else if (response.statusCode == 400) {
      throw Exception("Invalid data submitted: $responseBody");
    } else {
      throw Exception("Failed to submit proposal: ${response.statusCode} - $responseBody");
    }

  } catch (e, stackTrace) {
    print('===================================');
    print(' NULL CHECK ERROR DETAILS:');
    print(' Error: $e');
    print(' Stack trace: $stackTrace');
    print('===================================');
    throw Exception("Error submitting proposal: $e");
  }
}
  // In fetchProposals method
static Future<List<Proposal>> fetchProposals() async {
  final String? token = await _getUserToken();
  final url = Uri.parse(proposalsUrl);  
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', 
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Proposal.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load proposals: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error loading proposals: $e");
  }
}

// In fetchContracts method  
Future<List<Contract>> fetchContracts() async {
  final String? token = await _getUserToken();
  final url = Uri.parse("$baseUrl/contracts/");
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
    },
  );

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


  