import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:koukicons/conferenceCall.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/providers/server.dart';
import 'package:snaplify/screens/challengeDetails.dart';
import 'package:snaplify/screens/chatScreen.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/confirmDialog.dart';

class ChallengeGameScreen extends StatefulWidget {
  static const routeName = '/game';
  final Challenge challenge;
  ChallengeGameScreen({Key key, @required this.challenge}) : super(key: key);
  @override
  _ChallengeGameScreenState createState() => _ChallengeGameScreenState();
}

class _ChallengeGameScreenState extends State<ChallengeGameScreen> {
  String _word = "";
  bool _isLoading = false;
  bool isFABClicked = true;
  Challenge challenge;
  FriendShipStatus status = FriendShipStatus.NoConnection;
  TextEditingController textEditingController = TextEditingController();

  bool hasError = false;

  int points = 10;

  final List<Color> _imageWidgetColor = [
    Color(0xFFd8a0ae),
    Color(0xFFc26e77),
    Color(0xFF4863A0),
    Color(0xFF008080)
  ];

  //Custom image loader
  void moiBitDownload() async {
    final url = 'https://kfs4.moibit.io/moibit/v0/readfile';
    assert(challenge.images.length <= 4);
    for (int i = 0; i < 4; ++i) {
      if (challenge.images[i] != null) continue;
      final data = {"fileName": challenge.cId + i.toString()};
      final encodedData = json.encode(data);
      http.Response response = await http.post(url,
          headers: {
            "api_key": "12D3KooWJn8t1aFq8WjYiHCshBAwvDQH8wDFY5Y2Ue2ZPna89Zgb",
            "api_secret":
                "080112407b10de977fde0a6dca066d04a40dff20ebf89b37f88ca9555d46f6e478a1f1d18526fecf3b4addea43ee4ae51248c1bdb0f9c8507e696d56ee55926f384dfa08",
          },
          body: encodedData);
      final base64String = base64.encode(response.bodyBytes);
      challenge.images[i] = base64Decode(base64String);
      if (mounted) setState(() {});
    }
  }

  Widget _imageWidget({int id, dynamic media, Challenge challenge}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(0),
          color: _imageWidgetColor[id],
          height: media.height * 0.26,
          width: media.width * 0.45,
          child: Center(
              child: (challenge.images[id] != null)
                  ? FlatButton(
                      child: Image.memory(challenge.images[id]),
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             FullPhoto(url: challenge.images[id])));
                      },
                    )
                  : Image(
                      image: AssetImage('assets/images/loadingimage.gif')))),
    );
  }

  Future<void> getFriendShipStatus() async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    FriendShipStatus result = await Provider.of<Server>(context, listen: false)
        .getFriendshipStatus(userId, challenge.byId);
    if (mounted)
      this.setState(() {
        status = result;
        isFABClicked = false;
      });
  }

  void _fabClickEvent() async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final currentUser = Provider.of<Auth>(context, listen: false).userDetails;
    this.setState(() {
      isFABClicked = true;
    });
    if (status == FriendShipStatus.MyFriend) {
      Users user = Users(
          uId: challenge.byId,
          name: challenge.byName,
          email: null,
          imageUrl: challenge.byImageUrl,
          points: 0);
      Navigator.of(context).pushNamed(Chat.routeName, arguments: user);
    } else if (status == FriendShipStatus.RequestPending) {
      await Provider.of<Server>(context, listen: false).responseToRequest(
          new Users(
              uId: challenge.byId,
              email: null,
              name: challenge.byName,
              imageUrl: challenge.byImageUrl,
              points: null),
          currentUser,
          true);
      this.setState(() {
        status = FriendShipStatus.MyFriend;
      });
      Fluttertoast.showToast(
          msg: 'Challenger added to Friend List!',
          textColor: Colors.white,
          backgroundColor: Colors.purple);
    } else if (status == FriendShipStatus.RequestSent) {
      await Provider.of<Server>(context, listen: false)
          .undoRequest(challenge.byId, userId);
      this.setState(() {
        status = FriendShipStatus.NoConnection;
      });
      Fluttertoast.showToast(
          msg: 'Removed Friend Request sent by you!',
          textColor: Colors.white,
          backgroundColor: Colors.purple);
    } else if (status == FriendShipStatus.NoConnection) {
      await Provider.of<Server>(context, listen: false)
          .sendRequest(challenge.byId, currentUser);
      Fluttertoast.showToast(
          msg: 'Sent Friend Request to challenger!',
          textColor: Colors.white,
          backgroundColor: Colors.purple);
      this.setState(() {
        status = FriendShipStatus.RequestSent;
      });
    }
    this.setState(() {
      isFABClicked = false;
    });
  }

  void _getHint() async {
    if (challenge.hints.length >= min(challenge.word.length - 2, 3)) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return CustomAlertDialog(
                title: "Maximum Hints Used!",
                message: "Sorry, you have used all your hints!");
          });
      return;
    }

    final userResponse = await showDialog(
        context: context,
        builder: (ctx) {
          return CustomConfirmDialog(
            title: "Use a Hint",
            message:
                "Are you sure you want to use a Hint? Note that for each Hint, your reward Ingots will be reduced!",
          );
        });

    if (!userResponse) return;

    final hintResponse =
        await Provider.of<Server>(context, listen: false).getHints(challenge);
    await showDialog(
        context: context,
        builder: (ctx) {
          return CustomAlertDialog(
              title: "New Hint Unlocked!",
              message: "You have unlocked a new Hint!");
        });
    Challenge newChallenge = new Challenge(
        cId: challenge.cId,
        byId: challenge.byId,
        byImageUrl: challenge.byImageUrl,
        byName: challenge.byName,
        done: challenge.done,
        dateTime: challenge.dateTime,
        word: challenge.word,
        hints: challenge.hints,
        isGlobal: challenge.isGlobal,
        images: challenge.images,
        countDone: challenge.countDone,
        doneBy: challenge.doneBy);
    setState(() {
      challenge = newChallenge;
    });
  }

  @override
  initState() {
    super.initState();
    if (mounted) {
      setState(() {
        challenge = widget.challenge;
      });
      moiBitDownload();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getFriendShipStatus();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final currentUser = Provider.of<Auth>(context, listen: false).userDetails;
    final media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Solve Snap-Challenge"),
        actions: [
          if (challenge.byId != userId)
            IconButton(icon: Icon(Icons.help), onPressed: _getHint),
          if (challenge.byId == userId && !challenge.isGlobal)
            IconButton(
                icon: KoukiconsConferenceCall(),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                      ChallengeDoneDetails.routeName,
                      arguments: challenge);
                })
        ],
      ),
      body: (_isLoading)
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                (challenge.done)
                    ? SizedBox(
                        height: media.height * 0.02,
                      )
                    : Column(children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20,
                                media.height * 0.01, 20, media.height * 0.01),
                            child: Text('Guess the Word',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ))),
                        Padding(
                            padding: EdgeInsets.fromLTRB(20,
                                media.height * 0.01, 20, media.height * 0.01),
                            child: PinCodeTextField(
                              textCapitalization: TextCapitalization.characters,
                              appContext: context,
                              textStyle: TextStyle(color: Colors.white),
                              backgroundColor: Colors.transparent,
                              length: challenge.word.length,
                              keyboardType: TextInputType.text,
                              animationType: AnimationType.fade,
                              onChanged: (value) {
                                _word = value.toLowerCase();
                              },
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.circle,
                                activeColor: Colors.purple,
                                inactiveColor: Colors.white,
                              ),
                            )),
                      ]),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _imageWidget(
                              id: 0, media: media, challenge: challenge),
                          _imageWidget(
                              id: 1, media: media, challenge: challenge)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _imageWidget(
                              id: 2, media: media, challenge: challenge),
                          _imageWidget(
                              id: 3, media: media, challenge: challenge)
                        ],
                      )
                    ],
                  ),
                ),
                challenge.hints.length > 0
                    ? Column(
                        children: [
                          for (var i = 0; i < challenge.hints.length; i++)
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                    'Letter at position ${challenge.hints[i] + 1} : ${challenge.word[challenge.hints[i]].toUpperCase()}'))
                        ],
                      )
                    : Text(""),
                challenge.hints.length > 0
                    ? SizedBox(height: media.height * 0.005)
                    : SizedBox(height: media.height * 0.03),
                (challenge.done)
                    ? Text(
                        "The word is ${challenge.word.toUpperCase()}",
                        textAlign: TextAlign.center,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 80, right: 80),
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                print(_word);
                                if (_word.toLowerCase() ==
                                    challenge.word.toLowerCase()) {
                                  await Provider.of<Server>(context,
                                          listen: false)
                                      .correctGuess(challenge, currentUser);
                                  challenge.done = true;
                                  await showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return CustomAlertDialog(
                                            title: "Snap-Challenge Solved",
                                            message:
                                                "You have been rewarded with $points Ingots");
                                      });
                                } else {
                                  await showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return CustomAlertDialog(
                                            title: "Wrong Word",
                                            message: "Please try again");
                                      });
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              } catch (e) {
                                await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return CustomAlertDialog(
                                          title: "Something went wrong!",
                                          message:
                                              "Oops! Maybe the Internet broke down! Please try again after some time!");
                                    });
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            child: Text(
                              "Try",
                              style: TextStyle(color: Colors.white),
                            )),
                      )
              ],
            ),
      floatingActionButton: isFABClicked
          ? (null)
          : challenge.byId == userId
              ? null
              : FloatingActionButton(
                  backgroundColor: Colors.purple,
                  onPressed: _fabClickEvent,
                  child: (status == FriendShipStatus.NoConnection)
                      ? Icon(Icons.send)
                      : (status == FriendShipStatus.MyFriend)
                          ? Icon(Icons.chat)
                          : (status == FriendShipStatus.RequestPending)
                              ? Icon(Icons.add)
                              : Icon(Icons.cancel)),
    );
  }
}
