import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_project_page.dart';
import 'notification_input_page.dart';
import 'add_worker_page.dart';
import 'add_admin_page.dart'; // Import AddAdminPage
import 'project_view.dart';
import 'main.dart'; // Import the main.dart file to access LoginScreen

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear all stored preferences

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Projects'),
            Tab(text: 'Workers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProjectsTab(),
          WorkersTab(),
        ],
      ),
    );
  }
}

class ProjectsTab extends StatefulWidget {
  @override
  _ProjectsTabState createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  List<dynamic> _projects = [];
  bool _isLoading = true;

  static const String _projectsUrl = 'http://54.172.36.10:3000/api/projects';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedProjects = prefs.getString('projects');

    if (storedProjects != null) {
      setState(() {
        _projects = json.decode(storedProjects);
        _isLoading = false;
      });
    } else {
      _fetchProjects(); // Call API if no stored data
    }
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true; // Start loading indicator
    });
    try {
      final response = await http.get(Uri.parse(_projectsUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        List<dynamic> projectsList = decodedResponse.entries.map((entry) {
          return {
            'projectName': entry.value['projectName'],
            'projectOverview': entry.value['projectOverview'],
          };
        }).toList();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('projects', json.encode(projectsList));

        setState(() {
          _projects = projectsList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
    }
  }

  Future<void> _deleteProject(String projectName) async {
    final url =
        Uri.parse('http://54.172.36.10:3000/api/projects/deleteProject');

    final body = json.encode({'projectName': projectName});

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Project deleted successfully');
      await _fetchProjects();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project deleted successfully.')),
      );
    } else {
      print('Failed to delete project: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchProjects,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    projectName: _projects[index]['projectName'],
                    projectDescription: _projects[index]['projectOverview'],
                    onDelete: _deleteProject, // Pass the delete function
                  );
                },
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProjectPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text(
            'Add Project',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String projectDescription;
  final Future<void> Function(String) onDelete; // Function to delete project

  ProjectCard({
    required this.projectName,
    required this.projectDescription,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String displayDescription = projectDescription.length > 30
        ? projectDescription.substring(0, 30) + '...'
        : projectDescription;

    return Card(
      child: ListTile(
        title: Text(projectName),
        subtitle: Text(displayDescription),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailPage(
                      projectName: projectName,
                      projectDescription: projectDescription,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Project'),
                    content:
                        Text('Are you sure you want to delete this project?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          onDelete(
                              projectName); // Call delete function with project name
                          Navigator.of(context).pop();
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('No'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WorkersTab extends StatefulWidget {
  @override
  _WorkersTabState createState() => _WorkersTabState();
}

class _WorkersTabState extends State<WorkersTab> {
  List<dynamic> _workers = [];
  bool _isLoading = true;

  static const String _workersUrl = 'http://54.172.36.10:3000/api/workers';

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedWorkers = prefs.getString('workers');

    if (storedWorkers != null) {
      setState(() {
        _workers = json.decode(storedWorkers);
        _isLoading = false;
      });
    } else {
      _fetchWorkers();
    }
  }

  Future<void> _fetchWorkers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(_workersUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        List<dynamic> workersList = decodedResponse.entries.map((entry) {
          return {
            'id': entry.key,
            'fullName': entry.value['fullName'] ?? 'Unknown',
            'contactNumber': entry.value['contactNumber'] ?? 'N/A',
            'username': entry.value['username'] ?? '',
            'role': entry.value['role'] ?? 'WORKER',
          };
        }).toList();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('workers', json.encode(workersList));

        setState(() {
          _workers = workersList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
    }
  }

  Future<void> _deleteWorker(String username) async {
    final url = Uri.parse('http://54.172.36.10:3000/api/workers/deleteWorker');
    final body = json.encode({'username': username});
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Worker deleted successfully');
      await _fetchWorkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Worker deleted successfully.')),
      );
    } else {
      print('Failed to delete worker: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchWorkers,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: _workers.length,
                itemBuilder: (context, index) {
                  String username = _workers[index]['username'] ?? '';
                  return WorkerCard(
                    fullName: _workers[index]['fullName'] ?? 'Unknown',
                    contactNumber: _workers[index]['contactNumber'] ?? 'N/A',
                    username: username,
                    role: _workers[index]['role'] ?? 'WORKER',
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Worker'),
                          content: Text(
                              'Are you sure you want to delete this worker?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (username.isNotEmpty) {
                                  _deleteWorker(username);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Cannot delete worker with no username.')));
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('No'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAdminPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Add Admin',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddWorkerPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Add Worker',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final String fullName;
  final String contactNumber;
  final String username;
  final String role;
  final VoidCallback onDelete;

  WorkerCard({
    required this.fullName,
    required this.contactNumber,
    required this.username,
    required this.role,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Set card and text colors based on the role
    Color cardColor = role == 'ADMIN' ? Colors.blue : Colors.white;
    Color textColor = role == 'ADMIN' ? Colors.white : Colors.black;

    return Card(
      color: cardColor, // Apply background color to the card
      child: ListTile(
        title: Text(
          '$fullName (@$username)', // Display full name with username
          style: TextStyle(color: textColor), // Apply text color
        ),
        subtitle: Text(
          contactNumber,
          style: TextStyle(color: textColor), // Apply text color
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: textColor), // Color delete icon
          onPressed: onDelete,
        ),
      ),
    );
  }
}
