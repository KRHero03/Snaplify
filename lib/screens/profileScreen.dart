import 'package:flutter/material.dart';
import 'package:snaplify/widgets/profile.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';
  final userId;
  ProfileScreen({@required this.userId});
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Profile"),
      ),
      body: Profile(userId: widget.userId),
    );
  }
}
