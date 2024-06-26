import 'dart:convert';

import 'package:chat_app_task/Functions/PrefsFunction.dart';
import 'package:chat_app_task/Screens/RegisterScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "", password = "";
  Map<String, dynamic> data = {};

  void Login() async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await readData(credential.user!.email!);
      PrefsFunction().setInitialPrefs(
        data["name"],
        credential.user!.email!,
        data["mobileNumber"],
      );
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              email: credential.user!.email!,
              name: data["name"],
              number: data["mobileNumber"],
            ),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> readData(String loginEmail) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("users/${loginEmail.replaceAll('@', '').replaceAll('.', '')}");
    DataSnapshot snapshot = await ref.get();
    data = jsonDecode(jsonEncode(snapshot.value));
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Email"),
            onChanged: (emailText) {
              email = emailText;
            },
          ),
          TextField(
            decoration: InputDecoration(hintText: "Password"),
            onChanged: (passwordText) {
              password = passwordText;
            },
          ),
          MaterialButton(
            onPressed: () {
              if (email.isNotEmpty && password.isNotEmpty) {
                Login();
              }
            },
            child: Text("Login"),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(),
                ),
              );
            },
            child: Text("Register User"),
          )
        ],
      ),
    );
  }
}
