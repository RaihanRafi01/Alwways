import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // For secure storage
  // Base URL for the API
  final String baseUrl = 'http://164.92.65.230:5002/api/';

  // Sign-up method with userData and profile picture
  Future<http.Response> signUp(
      String firstname, String lastname, String email, String mobile,
      String location, String gender, String dateOfBirth, String password,
      XFile profilePicture) async {

    // Construct the endpoint URL
    final Uri url = Uri.parse('${baseUrl}user/register/');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
    });

    // Add user data as a JSON string in the 'userData' field
    Map<String, String> userData = {
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "mobile": mobile,
      "location": location,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "password": password,
    };

    request.fields['userData'] = jsonEncode(userData);

    // Add the profile picture (if available)
    if (profilePicture != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
            'profilePicture',
            profilePicture.path,
            contentType: MediaType('image', 'jpeg') // Adjust MIME type if necessary
        ),
      );
    }

    // Send the request
    var response = await request.send();

    // Return the response
    return await http.Response.fromStream(response);
  }

  // login method
  Future<http.Response> login(String email, String password) async {
    // Construct the endpoint URL
    final Uri url = Uri.parse('${baseUrl}user/login/');

    // Headers for the HTTP request
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    // Request body
    final Map<String, String> body = {
      "email": email,
      "password": password,
    };

    // Make the POST request
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

}
