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
      home: AddAdminPage(),
    );
  }
}

class AddAdminPage extends StatefulWidget {
  @override
  _AddAdminPageState createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  // Function to submit worker data
  Future<void> _addWorker(String username, String password, String fullName,
      String contactNumber) async {
    // Validate input fields
    if (username.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        contactNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "role": "ADMIN",
      "fullName": fullName,
      "contactNumber": contactNumber,
      "dob": '2024-10-17',
      "doj": "2024-10-17", // Example join date
      "address": "add",
    };

    try {
      final url = Uri.parse(
          'http://54.172.36.10:3000/api/workers'); // Replace with your actual endpoint
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin added successfully!')),
        );
        Navigator.pop(context); // Go back after submission
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add admin: ${response.statusCode}')),
        );
        print('Response Body: ${response.body}'); // Log response for debugging
      }
    } catch (error) {
      // Catch any errors and print them
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Worker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Hide password input
            ),
            SizedBox(height: 20),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
              ),
              keyboardType:
                  TextInputType.phone, // Show numeric keyboard for phone number
            ),
            SizedBox(height: 40),
            Spacer(),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Align buttons to the edges
              children: [
                ElevatedButton(
                  onPressed: () {
                    final String username = _usernameController.text;
                    final String password = _passwordController.text;
                    final String fullName = _fullNameController.text;
                    final String contactNumber = _contactNumberController.text;
                    _addWorker(username, password, fullName,
                        contactNumber); // Pass values directly to the function
                  },
                  child: Text('Add Admin'),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }
}
