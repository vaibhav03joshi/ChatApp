import 'package:chat_app_task/Functions/PrefsFunction.dart';
import 'package:chat_app_task/Screens/GeneralChat.dart';
import 'package:chat_app_task/Screens/LoginScreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    required this.email,
    required this.name,
    required this.number,
    super.key,
  });
  String email, name, number;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> Contacts = [];

  void logout() async {
    await PrefsFunction().resetPrefs();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Text(widget.name),
            Text(widget.email),
            Text(widget.number),
            MaterialButton(
              onPressed: () {
                logout();
              },
              child: Text("Logout"),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Column(
        children: [
          MaterialButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralChat(name: widget.name),
                ),
              );
            },
            child: Text("General chat"),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: Contacts.length,
          //     itemBuilder: (context, index) => Container(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
