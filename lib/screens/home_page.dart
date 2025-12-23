import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: deprecated_member_use
// import 'package:googleapis_auth/auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();

  bool sending = false;

  // final String serverKey =
  //     "MIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQDJG89VklSB7uNz";

  Future<void> sendNotification() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both title and message.")),
      );
      return;
    }

    setState(() => sending = true);

    try {
      // Load service account JSON from assets
      final jsonString = await rootBundle.loadString(
        'video-downloader-admin-b4c12c0fe07e.json',
      );
      final serviceAccount = auth.ServiceAccountCredentials.fromJson(
        jsonDecode(jsonString),
      );

      // Define the required scope for FCM
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Get authenticated client (automatically gets fresh access token)
      final client = await auth.clientViaServiceAccount(serviceAccount, scopes);

      // Your Firebase project ID (from the JSON file or Firebase console)
      const projectId =
          'video-downloader-admin'; // ← CHANGE TO YOUR ACTUAL PROJECT ID

      // Build the message payload (for topic)
      final messagePayload = {
        'message': {
          'topic': 'all_users',
          'notification': {
            'title': titleController.text.trim(),
            'body': messageController.text.trim(),
          },
          // Optional: add custom data
          // 'data': {'key': 'value'},
        },
      };

      // Send the request
      final response = await client.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messagePayload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification sent successfully! 🎉")),
        );
        titleController.clear();
        messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.statusCode} - ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }

      client.close(); // Important: close the client
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => sending = false);
  }

  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          "Admin Notification Sender",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Center(
        child: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create New Notification",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Notification Title",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 20),

                      TextField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Notification Message",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: sending ? null : sendNotification,
                          child: sending
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Send Notification",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
