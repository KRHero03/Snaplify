import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/providers/server.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/userGrid.dart';

class ChallengeDoneDetails extends StatelessWidget {
  static const routeName = '/detailsdone';
  @override
  Widget build(BuildContext context) {
    final challenge = ModalRoute.of(context).settings.arguments as Challenge;
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: FutureBuilder(
        future: Provider.of<Server>(context, listen: false)
            .getChallengeDetails(challenge),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return CustomAlertDialog(
                title: "Something went wrong",
                message: "please check again",
              );
            return ListView(children: [
              if (snapshot.data[0].isNotEmpty) Text("Challenge completed by"),
              for (int i = 0; i < snapshot.data[0].length; ++i)
                UserGrid(snapshot.data[0][i], FriendShipStatus.MyFriend),
              Text("challenge assigned"),
              for (int i = 0; i < snapshot.data[1].length; ++i)
                UserGrid(snapshot.data[1][i], FriendShipStatus.MyFriend),
            ]);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
