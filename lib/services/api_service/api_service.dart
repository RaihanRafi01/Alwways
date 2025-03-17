import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../model/bookModel.dart';

class ApiService {
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // For secure storage
  // Base URL for the API
  final String baseUrl = 'http://164.92.65.230:5002/api/';
  final String baseUrl2 = 'http://144.126.209.250/';


  Future<http.Response> updateEpisodePercentage(String bookId, String episodeIndex, num percentage) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }
    final url = '${baseUrl}book/$bookId/episode/$episodeIndex';
    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['percentage'] = percentage.toString();

    print("Updating episode percentage: URL=$url, percentage=$percentage");
    return await request.send().then(http.Response.fromStream);
  }

  Future<http.Response> getQuestionsForSection(String episodeId) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }

    final url = '${baseUrl}question/questions/$episodeId';
    return await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.Response> getSections() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }
    final url = '${baseUrl}section/sections';
    return await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  // Generate sub-questions based on main question and answer
  Future<http.Response> generateSubQuestion(
      String mainQuestion, String mainAnswer) async {
    final url = '${baseUrl2}generate_sub_question/';
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'M_Q': mainQuestion, 'M_Q_A': mainAnswer}),
    );
  }

  // Save an answer for a book and episode
  Future<http.Response> saveAnswer(
      String bookId, String episodeId, String question, String answer) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }
    final url = '${baseUrl}book/$bookId/episode/$episodeId/answer';
    return await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'question': question, 'userAnswer': answer}),
    );
  }

  // Check relevancy of a sub-question and answer
  Future<http.Response> checkRelevancy(String question, String answer) async {
    final url = '${baseUrl2}CQ_relevancy_check/';
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'C_Q': question, 'C_Q_A': answer}),
    );
  }

  // Sign-up method with userData and profile picture
  Future<http.Response> signUp(
      String firstname,
      String lastname,
      String email,
      String mobile,
      String location,
      String gender,
      String dateOfBirth,
      String password,
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
        await http.MultipartFile.fromPath('profilePicture', profilePicture.path,
            contentType:
                MediaType('image', 'jpeg') // Adjust MIME type if necessary
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

  Future<http.Response> verifyOtp(String email, String otp) async {
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

  Future<http.Response> resetPassword(
      String email, String otp, String password) async {
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

    final Uri url =
        Uri.parse('${baseUrl}book/create/'); // Adjust endpoint as per API docs
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

  Future<http.Response> updateBookCover(
      String bookId, String title, XFile? coverImage) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }

    // Construct the endpoint URL (adjust based on your API documentation)
    final Uri url = Uri.parse('${baseUrl}book/$bookId');

    // Create a multipart request
    var request = http.MultipartRequest('PUT', url);

    // Add headers
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data",
    });

    // Add form data
    request.fields['title'] = title;

    // Add the cover image (if provided)
    if (coverImage != null) {
      print('::::::::::::::::::::::::::::NOT NULL IMAGE');
      request.files.add(
        await http.MultipartFile.fromPath(
          'coverImage', // Field name expected by your API
          coverImage.path,
          contentType: MediaType('image', 'jpeg'), // Adjust MIME type as needed
        ),
      );
    }

    // Send the request and convert to http.Response
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateEpisodeCover(
      String bookId, XFile? coverImage, int episode_number) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No token found');
    }
    print(' ::::::::::::::::::::::::::  bookId : $bookId');
    print(' ::::::::::::::::::::::::::  number : $episode_number');

    // Construct the endpoint URL (adjust based on your API documentation)
    final Uri url = Uri.parse('${baseUrl}book/$bookId/episode/$episode_number');

    // Create a multipart request
    var request = http.MultipartRequest('PUT', url);

    // Add headers
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data",
    });

    // Add the cover image (if provided)
    if (coverImage != null) {
      print('::::::::::::::::::::::::::::NOT NULL IMAGE');
      request.files.add(
        await http.MultipartFile.fromPath(
          'coverImage', // Field name expected by your API
          coverImage.path,
          contentType: MediaType('image', 'jpeg'), // Adjust MIME type as needed
        ),
      );
    }

    // Send the request and convert to http.Response
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
