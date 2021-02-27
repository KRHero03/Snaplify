import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/notification.dart';
import 'package:snaplify/providers/server.dart';
import 'package:snaplify/widgets/notification.dart';

class Notify extends StatefulWidget {
  final List<dynamic> notification;
  Notify({this.notification});
  static const routeName = '/notify';

  @override
  State<StatefulWidget> createState() => NotifyState();
}

class NotifyState extends State<Notify> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    widget.notification.sort((a, b) {
      if (DateTime.parse(a["dateTime"]).isAfter(DateTime.parse(b["dateTime"])))
        return 1;
      return 0;
    });
    return AnimatedBackground(
        behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
                baseColor: Colors.purple,
                spawnMinSpeed: 20,
                spawnMaxSpeed: 70,
                spawnMaxRadius: 30)),
        vsync: this,
        child: FutureBuilder(
            future: Provider.of<Server>(context, listen: false)
                .notificationSeen(widget.notification),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              return Container(
                  child: Center(
                      child: widget.notification.length == 0
                          ? Text('No Notifications Yet.',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold))
                          : ListView.builder(
                              itemBuilder: (ctx, ind) {
                                if (widget.notification[ind]["type"] ==
                                    NotificationType.FriendRequest.toString())
                                  return NotificationGrid(
                                      FriendRequestNotification(
                                          dateTime: DateTime.parse(widget
                                              .notification[ind]["dateTime"]),
                                          seen: widget.notification[ind][
                                              "seen"],
                                          byId: widget.notification[ind][
                                              "byId"],
                                          byName: widget.notification[ind]
                                              ["byName"],
                                          imageUrl: widget.notification[ind]
                                              ["imageUrl"]));

                                if (widget.notification[ind]["type"] ==
                                    NotificationType.FriendRequestAccepted
                                        .toString())
                                  return NotificationGrid(
                                      FriendRequestAcceptedNotification(
                                          dateTime: DateTime.parse(widget
                                              .notification[ind]["dateTime"]),
                                          seen: widget.notification[ind]
                                              ["seen"],
                                          byId: widget.notification[ind]
                                              ["byId"],
                                          byName: widget.notification[ind]
                                              ["byName"],
                                          imageUrl: widget.notification[ind]
                                              ["imageUrl"]));

                                if (widget.notification[ind]["type"] ==
                                    NotificationType.Bonus.toString())
                                  return NotificationGrid(BonusNotification(
                                      dateTime: DateTime.parse(
                                          widget.notification[ind]["dateTime"]),
                                      seen: widget.notification[ind]["seen"],
                                      days: widget.notification[ind]["days"],
                                      points: widget.notification[ind]
                                          ["points"],
                                      streakType: widget.notification[ind]
                                          ["streakType"]));

                                if (widget.notification[ind]["type"] ==
                                    NotificationType.ChallengeDone.toString())
                                  return NotificationGrid(
                                      ChallengeDoneNotification(
                                          dateTime: DateTime.parse(widget
                                              .notification[ind]["dateTime"]),
                                          seen: widget.notification[ind]
                                              ["seen"],
                                          byId: widget.notification[ind]
                                              ["byId"],
                                          byName: widget.notification[ind]
                                              ["byName"],
                                          imageUrl: widget.notification[ind]
                                              ["imageUrl"],
                                          hintCount: widget.notification[ind]
                                              ["hintCount"],
                                          word: widget.notification[ind]
                                              ["word"]));
                                return Container();
                              },
                              itemCount: widget.notification.length,
                            )));
            }));
  }
}
