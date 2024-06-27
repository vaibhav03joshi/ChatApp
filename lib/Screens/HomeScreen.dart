import 'dart:convert';

import 'package:chat_app_task/Functions/PrefsFunction.dart';
import 'package:chat_app_task/Screens/AllUsers.dart';
import 'package:chat_app_task/Screens/GeneralChat.dart';
import 'package:chat_app_task/Screens/LoginScreen.dart';
import 'package:firebase_database/firebase_database.dart';
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
  List<UserData> Contacts = [];

  @override
  void initState() {
    getContacts();
    print(widget.email);
    super.initState();
  }

  Future<void> getContacts() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "Users/${widget.email.replaceAll('@', '').replaceAll('.', '')}/Contacts/");
    DataSnapshot snapshot = await ref.get();
    Map<String, dynamic> data =
        jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
    data.forEach((key, value) async {
      await getContactsInformation(key, value);
    });
  }

  Future<void> getContactsInformation(String username, String value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Users/${username}");
    DataSnapshot snapshot = await ref.get();
    Map<String, dynamic> data =
        jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
    UserData userData =
        new UserData(data["name"], data["email"], data["mobileNumber"], value);
    Contacts.add(userData);
    setState(() {});
  }

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
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.person),
                    Text(widget.name),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.email),
                    Text(widget.email),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    Text(widget.number),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllUsers(
                          email: widget.email,
                          name: widget.name,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.group_add),
                      Text("All Users"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () {
                    logout();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      Text("Logout"),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  builder: (context) => GeneralChat(
                    name: widget.name,
                    path: "General/",
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.group),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("General chat"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Contacts.length,
              itemBuilder: (context, index) => MaterialButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneralChat(
                            name: widget.name,
                            path: "PersonalChat/${Contacts[index].value}/"),
                      ));
                },
                child: Row(
                  children: [
                    Icon(Icons.person),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Contacts[index].name),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
