import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyek2/models/pecahanModel.dart'; // Import Pecahan model

class PecahanController {
  // Replace with the correct base URL of your PHP server
  final String baseUrl = "https://doni.infonering.com/proyek/pecahan.php"; // Replace with your actual server URL

  // Method to fetch Pecahan data from an API
  Future<List<Pecahan>> fetchPecahan() async {
    try {
      // Construct the full URL with the 'endpoint' query parameter
      final Uri url = Uri.parse("$baseUrl?endpoint=pecahan");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // If the request is successful, parse the response body
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Map the JSON response to a list of Pecahan objects
        return jsonResponse.map((data) => Pecahan.fromJson(data)).toList();
      } else {
        // If the request failed, throw an exception
        throw Exception('Failed to load Pecahan');
      }
    } catch (e) {
      // Catch and throw any errors that occurred during the request
      throw Exception('Failed to fetch data: $e');
    }
  }
}
