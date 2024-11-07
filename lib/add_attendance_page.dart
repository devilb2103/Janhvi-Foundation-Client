import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format date
import 'package:image_picker/image_picker.dart'; // For image picker
import 'package:http/http.dart' as http; // Import the HTTP package
import 'dart:convert'; // For JSON encoding

class AddAttendancePage extends StatefulWidget {
  final String username;
  final List<String> projectNames; // Accept project names from WorkerPage

  // Constructor to accept worker ID and project names as parameters
  AddAttendancePage(
      {required workerID,
      required this.projectNames,
      required String this.username});

  @override
  _AddAttendancePageState createState() => _AddAttendancePageState();
}

class _AddAttendancePageState extends State<AddAttendancePage> {
  String?
      selectedProject; // No default project, this will be populated from the list
  DateTime selectedDate = DateTime.now(); // Default to today's date
  TextEditingController descriptionController = TextEditingController();
  File? _image; // Variable to hold selected image
  final String placeholderImagePath =
      'C:/dummy/path/to/placeholder.jpg'; // Placeholder path

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to submit attendance data
  Future<void> _submitAttendance() async {
    if (descriptionController.text.isEmpty || selectedProject == null) {
      // Ensure that the description and project selection are not null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final attendanceUrl = Uri.parse(
        'http://54.172.36.10:3000/api/attendance'); // Replace with actual endpoint

    // Prepare the attendance data
    final Map<String, dynamic> attendanceData = {
      'workerID': widget.username,
      'projectName': selectedProject!,
      'Date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'workDescription': descriptionController.text,
      'imagePath': _image?.path ??
          placeholderImagePath, // Use selected image or placeholder
    };

    try {
      // Make a POST request to submit attendance
      final response = await http.post(
        attendanceUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(attendanceData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance added successfully!')),
        );
        Navigator.pop(context); // Go back after submission
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add attendance')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Attendance'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedProject,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
                items: widget.projectNames.map((String project) {
                  return DropdownMenuItem<String>(
                    value: project,
                    child: Text(project),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProject = newValue;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(selectedDate)),
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16.0),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _submitAttendance,
              child: Text('SUBMIT'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('CANCEL'),
            ),
          ],
        ),
      ),
    );
  }
}
