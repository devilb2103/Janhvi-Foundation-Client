import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddProjectPage(),
    );
  }
}

class AddProjectPage extends StatefulWidget {
  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  bool _isTyping = false;
  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectOverviewController = TextEditingController();

  // Function to submit project data
  Future<void> _submitProject() async {
    String projectName = projectNameController.text;
    String projectOverview = projectOverviewController.text;

    // Ensure that both fields are filled
    if (projectName.isEmpty || projectOverview.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Create a request for the API
    final url = Uri.parse(
        'http://54.172.36.10:3000/api/projects'); // Update the endpoint if needed
    final Map<String, dynamic> data = {
      "projectName": projectName,
      "projectOverview": projectOverview,
      "workers": [""] // Pass workers as an array with an empty string
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      // Check for successful response (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project added successfully!')),
        );
        Navigator.pop(context); // Go back after submission
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add project: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
          setState(() {
            _isTyping = false; // Change back the UI when tapping outside
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Project Name Input Field
              _buildTextField(
                'Project Name',
                (value) {
                  setState(() {
                    _isTyping = true;
                  });
                },
                projectNameController,
              ),
              SizedBox(height: 20),

              // Project Overview Input Field
              _buildTextField(
                'Project Overview',
                (value) {
                  setState(() {
                    _isTyping = true;
                  });
                },
                projectOverviewController,
              ),
              Spacer(),

              // Submit and Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submitProject, // Call submit function
                    child: Text('SUBMIT'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close page on Cancel
                    },
                    child: Text('CANCEL'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text field with custom decoration
  Widget _buildTextField(String label, Function(String) onChanged,
      TextEditingController controller) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _isTyping ? Colors.grey[200] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller, // Use the passed controller
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              controller.clear(); // Clear the text field
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    projectNameController.dispose();
    projectOverviewController.dispose();
    super.dispose();
  }
}
