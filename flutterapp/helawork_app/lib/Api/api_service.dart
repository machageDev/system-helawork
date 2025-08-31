

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService{
  static const String baseUrl = 'http://192.168.188.100:8000';
  static const String registerUrl = '$baseUrl/apiregister';
  static const String  loginUrl ='$baseUrl/apilogin';

 Future<Map<String, dynamic>>register(
    String name,String email, String password,String phoneNO ) async{
      final url = Uri.parse(registerUrl);
      try{
        final response = await http.post(
          url,
          headers:{"content-Type ":"application/json"},
          body:jsonEncode({
            "name":name,
            "email":email,
            "password":password,
            "phoneNO":phoneNO,
          }),
        );
        if (response.statusCode == 201){
          return {"success":true};
            
        }else{
          return{"success":false,"message":jsonDecode(response.body)["error"]};
        }
      }catch(e){
        return{"success":false,"message":"Network error,please try again."};
      }
    }
}

Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('apilogin');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": "Invalid credentials"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }