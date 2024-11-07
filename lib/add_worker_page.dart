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
      home: AddWorkerPage(),
    );
  }
}

class AddWorkerPage extends StatefulWidget {
  @override
  _AddWorkerPageState createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to submit worker data
  Future<void> _addWorker() async {
    final String fullName = _nameController.text;
    final String contactNumber = _contactController.text;
    final String dob = _dobController.text;
    final String address = _addressController.text;
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    // Validate input fields
    if (fullName.isEmpty ||
        contactNumber.isEmpty ||
        dob.isEmpty ||
        address.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "role": "WORKER",
      "fullName": fullName,
      "contactNumber": contactNumber,
      "dob": dob,
      "doj":
          "2024-10-17", // Example join date, replace with actual data if needed
      "address": address,
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
          SnackBar(content: Text('Worker added successfully!')),
        );
        Navigator.pop(context); // Go back after submission
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add worker: ${response.statusCode}')),
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

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
      });
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
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Worker Name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () =>
                  _selectDate(context), // Call the select date function
              child: AbsorbPointer(
                child: TextField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                  ),
                  keyboardType:
                      TextInputType.none, // Prevent keyboard from appearing
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
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
              obscureText: true,
            ),
            SizedBox(height: 40),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addWorker,
                  child: Text('Add Worker'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
    _nameController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
