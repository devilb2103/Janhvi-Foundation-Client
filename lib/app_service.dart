import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'http://54.172.36.10:3000'; // Change localhost to 10.0.2.2 for emulator
  String? _token; // Token to store the authentication token

  // Method to log in a user
  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': 'ADMIN', // Change the role as needed
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token']; // Store the token for future requests
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  // Method to get all projects
  Future<List<dynamic>> getProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/projects'),
          headers: _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  // Method to get page info for a specific worker
  Future<dynamic> getProjectsPageInfo(String username) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/api/projects/loadPageInfo?username=$username'),
          headers: _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load page info');
      }
    } catch (e) {
      throw Exception('Error fetching page info: $e');
    }
  }

  // Method to add a new project
  Future<void> addProject(
      String projectName, String projectOverview, List<String> workers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/projects'),
        headers: _getHeaders(),
        body: jsonEncode({
          'projectName': projectName,
          'projectOverview': projectOverview,
          'workers': workers,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding project: $e');
    }
  }

  // Method to delete a project
  Future<void> deleteProject(String projectName) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/projects/deleteProject'),
        headers: _getHeaders(),
        body: jsonEncode({
          'projectName': projectName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }

  // Method to get all workers
  Future<List<dynamic>> getWorkers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/workers'),
          headers: _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load workers');
      }
    } catch (e) {
      throw Exception('Error fetching workers: $e');
    }
  }

  // Method to add a new worker
  Future<void> addWorker(
      String username,
      String password,
      String role,
      String fullName,
      String contactNumber,
      String dob,
      String doj,
      String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/workers'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
          'fullName': fullName,
          'contactNumber': contactNumber,
          'dob': dob,
          'doj': doj,
          'address': address,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add worker: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding worker: $e');
    }
  }

  // Method to delete a worker
  Future<void> deleteWorker(String username) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/workers/deleteWorker'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete worker: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting worker: $e');
    }
  }

  // Method to get attendance for a worker
  Future<List<dynamic>> getWorkerAttendance(String workerID) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/api/attendance?workerID=$workerID'),
          headers: _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }

  // Method to add attendance for a worker
  Future<void> addWorkerAttendance(String workerID, String projectName,
      String date, String workDescription, String imagePath) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance'),
        headers: _getHeaders(),
        body: jsonEncode({
          'workerID': workerID,
          'projectName': projectName,
          'Date': date,
          'workDescription': workDescription,
          'imagePath': imagePath,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding attendance: $e');
    }
  }

  // Method to get a database backup
  Future<dynamic> getDBBackup() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/backup/GetDB'),
          headers: _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get database backup');
      }
    } catch (e) {
      throw Exception('Error fetching database backup: $e');
    }
  }

  // Method to get headers with authentication
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] =
          'Bearer $_token'; // Assuming Bearer token authentication
    }
    return headers;
  }
}
