import 'package:firebase_core/firebase_core.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/providers/challenge.dart';
import 'package:snaplify/providers/friendship.dart';
import 'package:snaplify/providers/notification.dart';
import 'package:snaplify/providers/user.dart';
import 'package:snaplify/screens/challengeDetails.dart';
import 'package:snaplify/screens/challengeGame.dart';
import 'package:snaplify/screens/chatScreen.dart';
import 'package:snaplify/screens/home.dart';
import 'package:snaplify/screens/createChallenge.dart';
import 'package:snaplify/screens/login.dart';
import 'package:snaplify/screens/shareChallenge.dart';
import 'package:snaplify/screens/profileScreen.dart';
import 'package:snaplify/screens/webView.dart';
import 'package:snaplify/widgets/fullphoto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ChallengesProvider>(
          create: (ctx) => ChallengesProvider(null),
          update: (ctx, auth, previousOrders) =>
              ChallengesProvider(auth.userId),
        ),
        ChangeNotifierProxyProvider<Auth, FriendDataProvider>(
          create: (ctx) => FriendDataProvider(null),
          update: (ctx, auth, previousOrders) =>
              FriendDataProvider(auth.userDetails),
        ),
        ChangeNotifierProxyProvider<Auth, NotificationProvider>(
          create: (ctx) => NotificationProvider(null),
          update: (ctx, auth, previousOrders) =>
              NotificationProvider(auth.userId),
        ),
        ChangeNotifierProxyProvider<Auth, UserDataProvider>(
          create: (ctx) => UserDataProvider(null),
          update: (ctx, auth, previousOrders) => UserDataProvider(auth.userId),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Snaplify',
          theme: ThemeData(
            primaryColor: Colors.purple,
            accentColor: Colors.purple,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.purple,
            accentColor: Colors.purple,
            appBarTheme: AppBarTheme(brightness: Brightness.light),
          ),
          home: auth.isUserSignedIn() ? HomeScreen() : LoginIn(),
          routes: {
            LoginIn.routeName: (ctx) => LoginIn(),
            CreateChallenge.routeName: (ctx) => CreateChallenge(),
            ShareChallenge.routeName: (ctx) => ShareChallenge(),
            ChallengeGameScreen.routeName: (ctx) => ChallengeGameScreen(
                  challenge: ModalRoute.of(ctx).settings.arguments,
                ),
            ChallengeDoneDetails.routeName: (ctx) => ChallengeDoneDetails(),
            Chat.routeName: (ctx) =>
                Chat(peer: ModalRoute.of(ctx).settings.arguments),
            ProfileScreen.routeName: (ctx) =>
                ProfileScreen(userId: ModalRoute.of(ctx).settings.arguments),
            FullPhoto.routeName: (ctx) =>
                FullPhoto(url: ModalRoute.of(ctx).settings.arguments),
            WebView.routeName: (ctx) => WebView()
          },
        ),
      ),
    );
  }
}
