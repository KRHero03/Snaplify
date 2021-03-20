import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/friendship.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/userGrid.dart';

class LeaderBoard extends StatefulWidget {
  static const routeName = '/leaderborad';

  @override
  State<StatefulWidget> createState() => LeaderboardState();
}

class LeaderboardState extends State<LeaderBoard>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
        behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
                baseColor: Colors.purple,
                spawnMinSpeed: 20,
                spawnMaxSpeed: 70,
                spawnMaxRadius: 30)),
        vsync: this,
        child: FutureBuilder(
          future: Provider.of<FriendDataProvider>(context, listen: false)
              .getFriendsWithPoints(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError)
                return CustomAlertDialog(
                    title: "Something went wrong",
                    message: "Please check your network",
                    disableButton: true);
              List<Users> _friends = snapshot.data;
              if (_friends.isEmpty)
                return Center(
                    child: Text(
                  "No Friends",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ));

              _friends.sort((a, b) {
                if (a.points < b.points)
                  return 1;
                else
                  return 0;
              });

              return ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (ctx, i) {
                    return UserGrid(_friends[i],
                        status: FriendShipStatus.MyFriend);
                  });
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }
}
