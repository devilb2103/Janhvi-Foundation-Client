import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'select_worker_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('API Test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Navigate to the project detail page with a sample project
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailPage(
                        projectName: "Project Teaching", // Example project name
                        projectDescription: "Description of the project.",
                      ),
                    ),
                  );
                },
                child: Text('Go to Project Detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDetailPage extends StatefulWidget {
  final String projectName;
  final String projectDescription;

  ProjectDetailPage(
      {required this.projectName, required this.projectDescription});

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  List<String> workerNames = [];
  List<String> workerUsernames = [];
  Map<String, List<Attendance>> workerAttendance = {};
  Map<String, int> attendanceCount = {}; // Store attendance counts as integers
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getWorkersNamesByProject(widget
        .projectName); // Fetch worker names when the widget is initialized
  }

  Future<void> getWorkersNamesByProject(String projectName) async {
    final url = Uri.parse('http://54.172.36.10:3000/api/projects');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic>) {
          String? foundProjectName;

          responseData.forEach((projectId, projectData) async {
            if (projectData is Map<String, dynamic>) {
              if (projectData['projectName'] == projectName) {
                foundProjectName = projectName;
                if (projectData.containsKey('workers')) {
                  List<String> workerUsernames =
                      List<String>.from(projectData['workers']);
                  await getWorkerDetails(workerUsernames);
                  await getAttendanceForWorkers(
                      workerUsernames); // Pass the project name
                }
              }
            }
          });

          if (foundProjectName != null) {
            print(
                'Workers Names for project "$foundProjectName": $workerNames');
          } else {
            print('Project "$projectName" not found.');
          }
        } else {
          print('Unexpected response format: $responseData');
        }
      } else {
        print('Failed to get projects: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      print('GET Workers API Error: $error');
    } finally {
      setState(() {
        isLoading = false; // Set loading to false after fetching
      });
    }
  }

  Future<void> getWorkerDetails(List<String> usernames) async {
    final workerUrl = Uri.parse('http://54.172.36.10:3000/api/workers');

    try {
      final workerResponse = await http.get(workerUrl);

      if (workerResponse.statusCode == 200) {
        final workerData = json.decode(workerResponse.body);

        if (workerData is Map<String, dynamic>) {
          List<String> fullNames = [];

          workerData.forEach((workerId, workerDetails) {
            if (workerDetails is Map<String, dynamic>) {
              String username = workerDetails['username'];
              if (usernames.contains(username)) {
                String fullName = workerDetails['fullName'];
                fullNames.add(fullName);
              }
            }
          });

          setState(() {
            workerNames = fullNames;
            workerUsernames = usernames; // Update workerNames with full names
          });

          if (fullNames.isNotEmpty) {
            print('Worker Full Names: $fullNames');
          } else {
            print('No workers found for the specified usernames.');
          }
        } else {
          print('Unexpected worker response format: $workerData');
        }
      } else {
        print('Failed to get workers: ${workerResponse.statusCode}');
        print('Response Body: ${workerResponse.body}');
      }
    } catch (error) {
      print('GET Worker Details API Error: $error');
    }
  }

  Future<void> getAttendanceForWorkers(List<String> usernames) async {
    for (String username in usernames) {
      final attendanceUrl = Uri.parse(
          'http://54.172.36.10:3000/api/attendance?workerID=$username');
      try {
        print('Fetching attendance for: $username');
        final response = await http.get(attendanceUrl);
        print('Attendance API Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final attendanceData = json.decode(response.body);
          print('Attendance Data for $username: $attendanceData');

          if (attendanceData is Map<String, dynamic>) {
            List<Attendance> attendanceList = [];
            attendanceCount[username] = 0; // Initialize count for the worker
            attendanceData.forEach((projectName, projects) {
              if (projectName == widget.projectName) {
                // Check if the project matches the current project
                projects.forEach((attendanceId, attendanceDetails) {
                  if (attendanceDetails is Map<String, dynamic>) {
                    Attendance attendance = Attendance(
                      projectName: projectName,
                      date: attendanceDetails['Date'],
                      workDescription: attendanceDetails['workDescription'],
                      imagePath: attendanceDetails['imagePath'],
                    );
                    attendanceList.add(attendance);
                    attendanceCount[username] =
                        attendanceList.length; // Count for the current project
                  }
                });
              }
            });

            // Debugging attendance count
            print(
                'Updated attendance count for $username: ${attendanceCount[username]}');

            setState(() {
              workerAttendance[username] =
                  attendanceList; // Update attendance map
            });
            print('Attendance for $username: $attendanceList');
          } else {
            print('Unexpected attendance data format: $attendanceData');
          }
        } else {
          print(
              'Failed to get attendance for $username: ${response.statusCode}');
          print('Response Body: ${response.body}');
        }
      } catch (error) {
        print('GET Attendance API Error for $username: $error');
      }
    }
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = true; // Set loading to true before fetching
    });
    await getWorkersNamesByProject(
        widget.projectName); // Fetch worker names again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the project list
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshData, // Call refresh function when clicked
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData, // Allow pull-to-refresh
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching data
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.projectName,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Description: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: widget.projectDescription),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: workerUsernames.length,
                        itemBuilder: (context, index) {
                          String workerName = workerUsernames[index];
                          List<Attendance>? attendance =
                              workerAttendance[workerName];

                          // Get the attendance count for the specific project
                          int projectAttendanceCount =
                              attendanceCount[workerName] ?? 0;

                          return WorkerCard(
                            workerName: workerName,
                            attendance: attendance ??
                                [], // Provide an empty list if null
                            projectAttendanceCount:
                                projectAttendanceCount, // Pass the count of attendance for the project
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        // Navigate to select worker page (if applicable)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectWorkerPage(
                                projectName: widget.projectName,
                                preSelectedUsernames: workerUsernames),
                          ),
                        );
                      },
                      child: Text('Add Worker'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final String workerName;
  final List<Attendance> attendance;
  final int projectAttendanceCount; // New parameter for attendance count

  WorkerCard(
      {required this.workerName,
      required this.attendance,
      required this.projectAttendanceCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.person),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        title: Text(
          '@$workerName',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attendance.isEmpty)
              Text(
                'Attendance Count: 0/20'
                '',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            else
              Text(
                'Attendance Count: $projectAttendanceCount/20'
                '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

// Attendance model class
class Attendance {
  final String projectName;
  final String date;
  final String workDescription;
  final String imagePath;

  Attendance({
    required this.projectName,
    required this.date,
    required this.workDescription,
    required this.imagePath,
  });

  @override
  String toString() {
    return 'Attendance(projectName: $projectName, date: $date, workDescription: $workDescription, imagePath: $imagePath)';
  }
}
