import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_attendance_page.dart';
import 'main.dart'; // Import the main.dart file to access LoginScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username') ??
      ''; // Fetch username from shared preferences

  runApp(MyApp(username: username)); // Pass the username to MyApp
}

class MyApp extends StatelessWidget {
  final String username; // Declare a variable to hold the username

  MyApp({required this.username}); // Accept username in the constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WorkerPage(username: username), // Pass the username to WorkerPage
    );
  }
}

// WorkerPage that fetches and displays projects based on the username
class WorkerPage extends StatefulWidget {
  final String username;

  WorkerPage({required this.username});

  @override
  _WorkerPageState createState() => _WorkerPageState();
}

class _WorkerPageState extends State<WorkerPage> {
  List<Project> projects = []; // List to store fetched projects
  Map<String, int> projectCounts =
      {}; // Map to store attendance counts for each project
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    getProjectNamesByUsername(
        widget.username); // Fetch project names based on username
  }

  // Function to get project names based on username
  Future<void> getProjectNamesByUsername(String username) async {
    final projectUrl = Uri.parse(
        'http://54.172.36.10:3000/api/projects/loadPageInfo?username=$username');

    try {
      // Make a GET request to fetch the projects
      final projectResponse = await http.get(projectUrl);

      if (projectResponse.statusCode == 200) {
        // Parse the response
        final List<dynamic> projectData = json.decode(projectResponse.body);

        // Extract project names and add them to the list
        List<Project> fetchedProjects = [];
        for (var project in projectData) {
          fetchedProjects.add(Project(
            name: project['project_name'],
            attendance: 'N/A', // Placeholder for attendance
          ));
        }

        setState(() {
          projects = fetchedProjects; // Update the state with fetched projects
          isLoading = false;
        });

        // Fetch attendance counts after getting project names
        fetchAttendanceData(username);
      } else {
        print('Failed to get projects: ${projectResponse.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('GET Projects API Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetch attendance data for the user
  Future<void> fetchAttendanceData(String username) async {
    final url = 'http://54.172.36.10:3000/api/attendance?workerID=$username';

    try {
      // Make the GET request
      print('Fetching data from: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response received successfully.');
        // Decode the JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Decoded JSON: $data');

        // Calculate the number of entries in each project
        Map<String, int> counts = {};
        data.forEach((projectName, projectEntries) {
          // Ensure projectEntries is a Map
          if (projectEntries is Map) {
            // Count the number of entries (unique IDs)
            counts[projectName] = projectEntries.length;
          } else {
            counts[projectName] = 0; // Set count to 0 if entries are not a Map
          }
        });

        setState(() {
          projectCounts = counts; // Update the attendance counts
        });
      } else {
        print('Failed to load attendance data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  // Logout function to clear user data from SharedPreferences
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    // Navigate back to the LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Function to refresh the project list
  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    await getProjectNamesByUsername(
        widget.username); // Fetch the projects again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - ${widget.username}'), // Displaying the username
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout, // Call the logout function
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // Link the refresh function here
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching data
            : ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final attendanceCount = projectCounts[project.name] ??
                      0; // Get attendance count or default to 0
                  return ProjectCard(
                    project: project,
                    attendanceCount:
                        attendanceCount, // Pass attendance count to ProjectCard
                  );
                },
              ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Extract project names from the 'projects' list
            List<String> projectNames =
                projects.map((project) => project.name).toList();

            // Pass the project names and other necessary fields when navigating
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAttendancePage(
                  username: widget.username,
                  workerID: '', // Pass worker ID here
                  projectNames: projectNames, // Pass the project names list
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976D2),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'ADD ATTENDANCE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Project {
  final String name;
  final String attendance;

  Project({required this.name, required this.attendance});
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final int attendanceCount;

  ProjectCard({required this.project, required this.attendanceCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          project.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            'Total Attendance: $attendanceCount/20'), // Show attendance count
      ),
    );
  }
}
