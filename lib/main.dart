import 'package:chat_app_task/Screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/HomeScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isLogin = await loadUser();
  runApp(MyApp(
    isLogin: isLogin,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({required this.isLogin, super.key});
  bool isLogin;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLogin
          ? HomeScreen(
              email: email,
              name: name,
              number: name,
            )
          : LoginScreen(),
    );
  }
}

Map<String, dynamic> data = {};
String email = "", password = "", name = "";
Future<bool> loadUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLogin = prefs.getBool("isLogin") ?? false;
  print(isLogin);
  if (!isLogin) {
    return isLogin;
  }
  password = prefs.getString("password") ?? "";
  email = prefs.getString("email") ?? "";
  name = prefs.getString("name") ?? "";
  print(email);
  print(name);
  print(password);
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    print(credential.user?.email);
    return true;
    // ignore: use_build_context_synchronously
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
  return false;
}
