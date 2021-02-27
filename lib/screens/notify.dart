import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';

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
    return AnimatedBackground(
        behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
                baseColor: Colors.purple,
                spawnMinSpeed: 20,
                spawnMaxSpeed: 70,
                spawnMaxRadius: 30)),
        vsync: this,
        child: Container(
            child: Center(
                child: widget.notification.length == 0
                    ? Text('No Notifications Yet.',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold))
                    : Text(widget.notification.toString()))));
  }
}
