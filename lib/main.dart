import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/screens/home.dart';
import 'package:snaplify/screens/createchallenge.dart';
import 'package:snaplify/screens/friends.dart';
import 'package:snaplify/screens/challenges.dart';
import 'package:snaplify/screens/leaderboard.dart';
import 'package:snaplify/screens/login.dart';
import 'package:snaplify/screens/notify.dart';
import 'package:snaplify/screens/profile.dart';
import 'package:snaplify/screens/sharechallenge.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Snaplify',
          theme: ThemeData(
            primaryColor: Colors.purple,
            accentColor: Colors.white,

            //TODO: add primary font
            // fontFamily: 'OpenSans',
          ),
          home: HomeScreen(),
          routes: {
            LoginIn.routeName: (ctx) => LoginIn(),
            Challenge.routeName: (ctx) => Challenge(),
            Notify.routeName: (ctx) => Notify(),
            Profile.routeName: (ctx) => Profile(),
            Friends.routeName: (ctx) => Friends(),
            LeaderBoard.routeName: (ctx) => LeaderBoard(),
            CreateChallenge.routeName: (ctx) => CreateChallenge(),
            ShareChallenge.routeName: (ctx) => ShareChallenge(),
          },
        ),
      ),
    );
  }
}
