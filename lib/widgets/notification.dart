import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:koukicons/diamond.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/notification.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/screens/profileScreen.dart';

class NotificationGrid extends StatelessWidget {
  final data;
  NotificationGrid(this.data);
  Widget getUserImage(String imageUrl) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                strokeWidth: 1.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
              width: 35.0,
              height: 35.0,
              padding: EdgeInsets.all(10.0),
            ),
            imageUrl: imageUrl,
            width: 35.0,
            height: 35.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(18.0),
          ),
          clipBehavior: Clip.hardEdge,
        ));
  }

  Widget friendRequest(FriendRequestNotification data, context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProfileScreen.routeName, arguments: data.byId);
        },
        child: Card(
          child: ListTile(
            leading: getUserImage(data.imageUrl),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${data.byName} send you a friend request"),
            ),
            trailing: Icon(Icons.more),
          ),
        ),
      ),
    );
  }

  Widget friendRequestAccepted(
      FriendRequestAcceptedNotification data, context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProfileScreen.routeName, arguments: data.byId);
        },
        child: Card(
          child: ListTile(
              leading: getUserImage(data.imageUrl),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${data.byName} accepted your friend request"),
              ),
              trailing: Icon(Icons.more)),
        ),
      ),
    );
  }

  Widget challengeDone(ChallengeDoneNotification data, context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProfileScreen.routeName, arguments: data.byId);
        },
        child: Card(
          child: ListTile(
            leading: getUserImage(data.imageUrl),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "${data.byName} guessed ${data.word} and with ${data.hintCount} hints"),
            ),
            trailing: Icon(Icons.more),
          ),
        ),
      ),
    );
  }

  Widget bonus(BonusNotification data, String userId, context) {
    //streakType can be "creating challenges" or "completing challenges"
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProfileScreen.routeName, arguments: userId);
        },
        child: Card(
          child: ListTile(
            leading: KoukiconsDiamond(),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "You have earned ${data.points} Ingots for your ${data.days} Streak of ${data.streakType}"),
            ),
            trailing: Icon(Icons.more),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    if (data.runtimeType == FriendRequestNotification)
      return friendRequest(data, context);
    if (data.runtimeType == FriendRequestAcceptedNotification)
      return friendRequestAccepted(data, context);
    if (data.runtimeType == ChallengeDoneNotification)
      return challengeDone(data, context);
    if (data.runtimeType == BonusNotification)
      return bonus(data, userId, context);
    return Container();
  }
}
