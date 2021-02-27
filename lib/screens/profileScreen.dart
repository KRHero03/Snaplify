import 'package:flutter/material.dart';
import 'package:snaplify/screens/profile.dart';
import 'package:snaplify/screens/search_bar.dart';

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
        title: Text('Profile'),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              }),
          // )
        ],
      ),
      body: Profile(userId: widget.userId),
    );
  }
}
