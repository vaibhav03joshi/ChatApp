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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Text(widget.name),
            Text(widget.email),
            Text(widget.number)
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Column(),
    );
  }
}
