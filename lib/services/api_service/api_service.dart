import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../model/bookModel.dart';

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

  Future<http.Response> forgotPasswordOTP(String email) async {
    // Construct the endpoint URL
    final Uri url = Uri.parse('${baseUrl}user/forgot-password/');

    // Headers for the HTTP request
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    // Request body
    final Map<String, String> body = {
      "email": email,
    };

    // Make the POST request
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> verifyOtp(String email,String otp) async {
    // Construct the endpoint URL
    final Uri url = Uri.parse('${baseUrl}user/verify-code-user/');

    // Headers for the HTTP request
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    // Request body
    final Map<String, String> body = {
      "email": email,
      "code": otp,
    };

    // Make the POST request
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> resetPassword(String email,String otp,String password) async {
    // Construct the endpoint URL
    final Uri url = Uri.parse('${baseUrl}user/reset-password/');

    // Headers for the HTTP request
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    // Request body
    final Map<String, String> body = {
      "email": email,
      "code": otp,
      "password": password,
      "confirmPassword": password,
    };

    // Make the POST request
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // New method to create a book
  Future<http.Response> createBook(String bookName) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }

    final Uri url = Uri.parse('${baseUrl}book/create/'); // Adjust endpoint as per API docs
    var request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers.addAll({
      "Authorization": "Bearer $token",
    });

    // Add form data (title as book name)
    request.fields['title'] = bookName;

    // Send the request and convert to http.Response
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<List<Book>> getAllBooks() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }
    final Uri url = Uri.parse('${baseUrl}book/user-books/');
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }

}
