import 'package:flutter/services.dart';
import 'package:snaplify/screens/webView.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        body: AnimatedBackground(
      behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
              baseColor: Colors.purple,
              spawnMinSpeed: 20,
              spawnMaxSpeed: 70,
              spawnMaxRadius: 30)),
      vsync: this,
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
            child: Text("Snaplify",
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(WebView.routeName, arguments: {
                      "url":
                          "https://itsmihir.github.io/Snaplify-Web/public/html/t&c.html",
                      "title": "Terms and Conditions"
                    });
                  },
                  child: Text(
                    "Terms and Conditions",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
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
    ));
  }
}
