

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService{
  static const String baseUrl = 'http://192.168.100.188:8000';
  static const String registerUrl = '$baseUrl/apiregister';
  static const String  loginUrl ='$baseUrl/apilogin';

Future<Map<String, dynamic>> register(String name, String email, String password, String phoneNO, String confirmPassword) async {
  final url = Uri.parse(registerUrl);
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "phone_number": phoneNO,
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


Future<Map<String, dynamic>> login(String name, String password) async { 
  final url = Uri.parse(loginUrl);

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "password": password}),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      final responseData = jsonDecode(response.body);
      print("Backend response: $responseData");
      return {
        "success": false,
        "message": "Invalid credentials",
        "error": responseData,
      };
    }
  } catch (e) {
    print("Login error: $e");
    return {
      "success": false,
      "message": "Error: $e",
    };
  }
}

   Future<Map<String, dynamic>> getActiveSession() async {
    final response = await http.get(Uri.parse("active-session/"));
    return json.decode(response.body);
  }
 Future<Map<String, dynamic>> getEarnings() async {
    final response = await http.get(Uri.parse("earnings/"));
    return json.decode(response.body);
  }

   Future<List<dynamic>> getTasks() async {
    final response = await http.get(Uri.parse("tasks/"));
    return json.decode(response.body);
   }
}