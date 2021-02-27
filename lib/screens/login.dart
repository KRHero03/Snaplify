import 'package:snaplify/widgets/googlesigninbutton.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

class LoginIn extends StatefulWidget {
  static const routeName = '/login';
  @override
  State createState() => LoginState();
}

class LoginState extends State<LoginIn> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedBackground(
      behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
              baseColor: Colors.purple,
              spawnMinSpeed: 20,
              spawnMaxSpeed: 70,
              spawnMaxRadius: 30)),
      vsync: this,
      child: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                  )),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("Snapify",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Diversify the Game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GoogleSignInButton(),
              Spacer(),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text("V 0.0.1"),
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text("© Copyright 2021 - Present"),
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text("All Rights Reserved | Team XLR8"),
                  )),
            ],
          ),
        ),
      ),
    ));
  }
}
