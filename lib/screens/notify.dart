import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/notification.dart';
import 'package:snaplify/providers/notification.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/notification.dart';

class Notify extends StatefulWidget {
  final List<dynamic> notification;
  Notify({this.notification});
  static const routeName = '/notify';

  @override
  State<StatefulWidget> createState() => NotifyState();
}

class NotifyState extends State<Notify> with TickerProviderStateMixin {
  String last = "999999";
  bool _doneLoading = false;
  bool _isLoading = true;
  int newNotifications = 0;
  List<dynamic> notification = [];
  bool _loadReqPending = false;
  @override
  void initState() {
    super.initState();
    notification = widget.notification;
    newNotifications = widget.notification.length;
    Provider.of<NotificationProvider>(context, listen: false)
        .notificationSeen(notification)
        .then((value) {
      if (notification.isNotEmpty) last = notification.last["dateTime"];
      if (notification.length < 3) {
        _loadReqPending = true;
        Provider.of<NotificationProvider>(context, listen: false)
            .getNotification(last)
            .then((value) {
          notification.addAll(value);
          if (mounted)
            setState(() {
              _isLoading = false;
            });
          _loadReqPending = false;
        });
      } else {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    }).catchError((onError) {
      CustomAlertDialog(
          title: "Something went wrong",
          message: "Check your internet",
          disableButton: true);
    });
  }

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
        child: (_isLoading)
            ? Center(child: CircularProgressIndicator())
            : notification.isEmpty && _doneLoading
                ? Center(
                    child: Text('No Notifications Yet.',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)))
                : ListView.builder(
                    itemBuilder: (ctx, ind) {
                      if (ind >= notification.length) {
                        if (_doneLoading) return null;
                        if (notification.isNotEmpty)
                          last = notification.last["dateTime"];
                        if (!_loadReqPending) {
                          _loadReqPending = true;
                          Provider.of<NotificationProvider>(context,
                                  listen: false)
                              .getNotification(last)
                              .then((value) {
                            if (value.isEmpty) _doneLoading = true;
                            notification.addAll(value);
                            if (mounted) setState(() {});
                            _loadReqPending = false;
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (notification[ind]["type"] ==
                          NotificationType.FriendRequest.toString())
                        return NotificationGrid(
                            FriendRequestNotification(
                                dateTime: DateTime.parse(
                                    notification[ind]["dateTime"]),
                                seen: notification[ind]["seen"],
                                byId: notification[ind]["byId"],
                                byName: notification[ind]["byName"],
                                imageUrl: notification[ind]["imageUrl"]),
                            (ind < newNotifications) ? false : true);

                      if (notification[ind]["type"] ==
                          NotificationType.FriendRequestAccepted.toString())
                        return NotificationGrid(
                            FriendRequestAcceptedNotification(
                                dateTime: DateTime.parse(
                                    notification[ind]["dateTime"]),
                                seen: notification[ind]["seen"],
                                byId: notification[ind]["byId"],
                                byName: notification[ind]["byName"],
                                imageUrl: notification[ind]["imageUrl"]),
                            (ind < newNotifications) ? false : true);

                      if (notification[ind]["type"] ==
                          NotificationType.Bonus.toString())
                        return NotificationGrid(
                            BonusNotification(
                                dateTime: DateTime.parse(
                                    notification[ind]["dateTime"]),
                                seen: notification[ind]["seen"],
                                days: notification[ind]["days"],
                                points: notification[ind]["points"],
                                streakType: notification[ind]["streakType"]),
                            (ind < newNotifications) ? false : true);

                      if (notification[ind]["type"] ==
                          NotificationType.ChallengeDone.toString())
                        return NotificationGrid(
                            ChallengeDoneNotification(
                                dateTime: DateTime.parse(
                                    notification[ind]["dateTime"]),
                                seen: notification[ind]["seen"],
                                byId: notification[ind]["byId"],
                                byName: notification[ind]["byName"],
                                imageUrl: notification[ind]["imageUrl"],
                                hintCount: notification[ind]["hintCount"],
                                word: notification[ind]["word"]),
                            (ind < newNotifications) ? false : true);
                      return Container();
                    },
                    itemCount: notification.length + 1,
                  ));
  }
}
