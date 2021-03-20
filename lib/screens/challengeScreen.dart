import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/providers/challenge.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/challengeGrid.dart';

class ChallengeScreen extends StatefulWidget {
  static const routeName = '/Challenge';

  @override
  State<StatefulWidget> createState() => ChallengeScreenState();
}

class ChallengeScreenState extends State<ChallengeScreen>
    with TickerProviderStateMixin {
  List<Challenge> challenges = [];
  bool _isLoading = true, _doneLoading = false, _loadReqPending = false;
  String lastPrivate = "999999";
  String lastPublic = "999999";
  @override
  void initState() {
    super.initState();
    _loadReqPending = true;
    Provider.of<ChallengesProvider>(context, listen: false)
        .getChallengesForHome(lastPrivate, lastPublic)
        .then((value) {
      challenges.addAll(value["challenges"]);
      lastPrivate = value["lastPrivate"];
      lastPublic = value["lastPublic"];
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      _loadReqPending = false;
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
            : ListView.builder(
                itemCount: challenges.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == challenges.length) {
                    if (_doneLoading) return null;
                    if (!_loadReqPending) {
                      _loadReqPending = true;
                      Provider.of<ChallengesProvider>(context, listen: false)
                          .getChallengesForHome(lastPrivate, lastPublic)
                          .then((value) {
                        if (value["challenges"].isEmpty) _doneLoading = true;
                        challenges.addAll(value["challenges"]);
                        lastPrivate = value["lastPrivate"];
                        lastPublic = value["lastPublic"];
                        if (mounted) setState(() {});
                        _loadReqPending = false;
                      });
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ChallengeGrid(challenges[i]);
                },
              ));
  }
}
