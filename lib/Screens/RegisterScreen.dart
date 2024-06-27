import 'package:chat_app_task/Screens/HomeScreen.dart';
import 'package:chat_app_task/Screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Functions/PrefsFunction.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = "", password = "", name = "", mobileNumber = "";

  void Register() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await WriteData(credential.user!.email!);
      PrefsFunction().setInitialPrefs(
          name, credential.user!.email!, mobileNumber, password);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(email: email, name: name, number: mobileNumber),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> WriteData(String LoginEmail) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("Users/${LoginEmail.replaceAll('@', '').replaceAll('.', '')}");

    await ref.set({
      "name": name,
      "mobileNumber": mobileNumber,
      "email": LoginEmail,
    });
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
            decoration: InputDecoration(
              hintText: "Password",
            ),
            onChanged: (passwordText) {
              password = passwordText;
            },
            keyboardType: TextInputType.number,
          ),
          TextField(
            decoration: InputDecoration(hintText: "Name"),
            onChanged: (nameText) {
              name = nameText;
            },
          ),
          TextField(
            decoration: InputDecoration(hintText: "Mobile Number"),
            onChanged: (mobileNumberText) {
              mobileNumber = mobileNumberText;
            },
          ),
          MaterialButton(
            onPressed: () {
              if (email.isNotEmpty &&
                  password.isNotEmpty &&
                  mobileNumber.isNotEmpty &&
                  name.isNotEmpty) {
                Register();
              }
            },
            child: Text("Register"),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            child: Text("Login"),
          )
        ],
      ),
    );
  }
}
