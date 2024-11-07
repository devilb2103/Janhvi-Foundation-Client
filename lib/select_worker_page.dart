import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectWorkerPage extends StatefulWidget {
  final String projectName;
  final List<String> preSelectedUsernames; // Add this line

  // Accept projectName and preSelectedUsernames via the constructor
  SelectWorkerPage({
    required this.projectName,
    required this.preSelectedUsernames, // Add this line
  });

  @override
  _SelectWorkerPageState createState() => _SelectWorkerPageState();
}

class _SelectWorkerPageState extends State<SelectWorkerPage> {
  List<Map<String, dynamic>> workers =
      []; // Keep it dynamic to avoid type issues
  final Map<String, bool> selectedWorkers = {}; // Store usernames for selection

  @override
  void initState() {
    super.initState();
    getWorkersNames();
  }

  // Function to get all workers' names from the API
  Future<void> getWorkersNames() async {
    final url = Uri.parse('http://54.172.36.10:3000/api/workers');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if responseData is a Map
        if (responseData is Map<String, dynamic>) {
          setState(() {
            // Extract worker usernames and names for workers with role 'WORKER'
            workers = responseData.values
                .where((worker) => worker['role'] == 'WORKER') // Filter by role
                .map((worker) => {
                      'username': worker['username'], // Store username
                      'fullName': worker['fullName'], // Store full name
                    })
                .toList();

            // Initialize selection state
            for (var worker in workers) {
              selectedWorkers[worker['username']] = widget.preSelectedUsernames
                  .contains(worker[
                      'username']); // Mark as selected if in pre-selected list
            }
          });
        } else {
          print('Unexpected response format: $responseData');
        }
      } else {
        print('Failed to get workers: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      print('GET Workers API Error: $error');
    }
  }

  // Function to update a project using PUT request
  Future<void> updateProjectApi() async {
    final url = Uri.parse('http://54.172.36.10:3000/api/projects');

    // Collect selected worker usernames
    final List<String> selectedUsernames = selectedWorkers.entries
        .where((entry) => entry.value) // Only get selected workers
        .map((entry) => entry.key)
        .toList();

    final Map<String, dynamic> projectData = {
      "projectName":
          widget.projectName, // Use projectName passed via constructor
      "workerUsernames": selectedUsernames,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(projectData),
      );

      // Check for successful response (200 or 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Project updated successfully'); // Success message
        Navigator.pop(context); // Go back to previous screen
      } else {
        print('Failed to update project: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      print('PUT Project API Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Workers'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: workers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(workers[index]['fullName']
                      as String), // Display only fullName
                  value: selectedWorkers[workers[index]
                      ['username']], // Use username for selection
                  onChanged: (bool? value) {
                    setState(() {
                      selectedWorkers[workers[index]['username']] =
                          value!; // Update selection state
                    });
                  },
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Call update project API with selected workers
                updateProjectApi();
              },
              child: Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back without making changes
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
