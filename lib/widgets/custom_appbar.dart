import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/screens/profile/profile_page.dart';

AppBar customAppBar({
  required BuildContext context,
  required bool isDarkMode,
  required VoidCallback toggleTheme,
  bool showGreeting = false,
  List<Widget>? actions,
  String? userName,
}) {
  return AppBar(
    elevation: 0,
    backgroundColor: isDarkMode ? Colors.black : Colors.teal,
    title: showGreeting
        ? Row(
            children: [
              Image.asset('assets/images/logo.png', height: 55),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hello, ${_getFirstName(userName)}'.tr(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        : Text('Smart LMS'.tr()),
    actions: actions ??
        [
          // 🔥 زر حالة الاتصال (جديد)
          // FutureBuilder<bool>(
          //   future: ConnectivityHelper.isConnected(),
          //   builder: (context, snapshot) {
          //     final isOnline = snapshot.data ?? true;
          //     return IconButton(
          //       icon: Icon(
          //         isOnline ? Icons.wifi : Icons.wifi_off,
          //         color: isOnline
          //             ? (isDarkMode ? Colors.green : Colors.black)
          //             : Colors.red,
          //       ),
          //       onPressed: () =>
          //           ConnectivityHelper.showConnectivityStatus(context),
          //       tooltip: isOnline ? 'Online'.tr() : 'Offline'.tr(),
          //     );
          //   },
          // ),

          // زر تغيير اللغة
          IconButton(
            icon: Icon(
              Icons.language,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              if (context.locale == const Locale('en')) {
                context.setLocale(const Locale('ar'));
              } else {
                context.setLocale(const Locale('en'));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Change Language'.tr()),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // زر تبديل الثيم
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: toggleTheme,
          ),

          // صورة البروفايل
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
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

String _getFirstName(String? fullName) {
  if (fullName == null || fullName.isEmpty) {
    return "Guest";
  }

  List<String> nameParts = fullName.trim().split(' ');
  return nameParts.first;
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
