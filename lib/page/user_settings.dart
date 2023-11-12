/// The page is for user settings
///
/// Author: Kuo Wei Wu


import 'package:flutter/material.dart';
import 'package:specon/models/user_model.dart';

class UserSettings extends StatefulWidget {
  final UserModel currentUser;

  const UserSettings(
      { Key? key,
        required this.currentUser,
      }
      ): super(key: key);


  @override
  State<UserSettings> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSettings> {
  bool emailNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('User Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Email Notification",
                    style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 20, letterSpacing: 1),
                  ),
                ),
                  Switch(
                  // This bool value toggles the switch.
                  value: emailNotification,
                  activeColor: Theme.of(context).colorScheme.secondary ,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      emailNotification = value;
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
