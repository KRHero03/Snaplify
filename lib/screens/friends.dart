import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/providers/friendship.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/userGrid.dart';

class Friends extends StatelessWidget {
  static const routeName = '/friends';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Provider.of<FriendDataProvider>(context, listen: false)
              .getFriends(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return CustomAlertDialog(
                  title: "Something went wrong",
                  message: "Please check your internet",
                  disableButton: true,
                );
              }
              if (snapshot.data.isEmpty)
                return Center(
                    child: Text("No Friends",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)));
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, i) {
                    return UserGrid(snapshot.data[i],
                        status: FriendShipStatus.MyFriend);
                  });
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
