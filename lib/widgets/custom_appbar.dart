import 'package:flutter/material.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';

AppBar customAppBar({
  required BuildContext context,
  required bool isDarkMode,
  required VoidCallback toggleTheme,
  bool showGreeting = false,
  List<Widget>? actions,
}) {
  return AppBar(
    elevation: 0,
    backgroundColor: isDarkMode ? Colors.black : Colors.teal,
    title: showGreeting
        ? Row(
      children: [
        Image.asset('assets/images/logo.png', height: 55),
        const SizedBox(width: 10),
        Text(
          'Hello, Adam',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    )
        : Text('smart_lms'' '),
    actions: actions ??
        [

          // زر تبديل الثيم
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: toggleTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      toggleTheme: toggleTheme,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile2.png'),
                radius: 20,
              ),
            ),
          ),
        ],
  );
}
/*
import 'package:flutter/material.dart';

AppBar customAppBar({required String username}) {
  return AppBar(
    backgroundColor: Colors.teal, // يمكنك تغيير اللون كما تريد
    elevation: 0,
    title: Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/images/logo.png'),
          radius: 16,
        ),
        SizedBox(width: 10),
        Text(
          'Hello, $username',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.notifications_none, color: Colors.black),
        onPressed: () {},
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile2.png'),
          radius: 16,
        ),
      ),
    ],
  );
}
*/
