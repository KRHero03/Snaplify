import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/providers/server.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/challengeGrid.dart';

class ChallengeScreen extends StatefulWidget {
  static const routeName = '/Challenge';

  @override
  State<StatefulWidget> createState() => ChallengeScreenState();
}

class ChallengeScreenState extends State<ChallengeScreen>
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
          future: Provider.of<Server>(context, listen: false)
              .getChallengesForHome(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.hasError)
                return CustomAlertDialog(
                    title: "Something went wrong",
                    message: "Check your internet",
                    disableButton: true);
              if (snapshot.data.isEmpty)
                return Center(child: Text("No Challenges Found"));
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (ctx, i) {
                  return ChallengeGrid(snapshot.data[i]);
                },
              );
            }
            if (snapshot.hasError) print(snapshot.error);
            return Center(child: CircularProgressIndicator());
          },
        ));
  }
}
