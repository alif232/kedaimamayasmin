import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginController {
  Future<void> login({
    required String username,
    required String password,
    required BuildContext context,
    required Function setLoading,
    required Function showErrorDialog,
  }) async {
    final String apiUrl = 'http://localhost/proyek/login.php';

    // Set loading state
    setLoading(true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['username'] = username;
      request.fields['password'] = password;

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      setLoading(false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        print('Parsed Response: $responseData');

        if (responseData['status'] == 'success') {
          String role = responseData['role'];
          if (role == 'Admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (role == 'Kasir') {
            Navigator.pushReplacementNamed(context, '/kasir');
          } else {
            showErrorDialog('Unknown role, please contact support.');
          }
        } else {
          showErrorDialog(responseData['message'] ?? 'Unknown error from API.');
        }
      } else {
        showErrorDialog('Server error, status code: ${response.statusCode}');
      }
    } catch (e) {
      setLoading(false);
      print('Error: $e');
      showErrorDialog('An error occurred: $e');
    }
  }
}
