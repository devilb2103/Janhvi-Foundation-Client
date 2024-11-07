import 'package:flutter/material.dart';

class NotificationInputPage extends StatefulWidget {
  @override
  _NotificationInputPageState createState() => _NotificationInputPageState();
}

class _NotificationInputPageState extends State<NotificationInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode()); // Open keyboard
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Notification Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode()); // Open keyboard
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement submission logic here
                    print('Notification submitted');
                    Navigator.pop(context);
                  },
                  child: Text('SUBMIT'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white70),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CANCEL'),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
