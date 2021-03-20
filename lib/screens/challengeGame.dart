import 'dart:async';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/providers/challenge.dart';
import 'package:snaplify/providers/friendship.dart';
import 'package:snaplify/screens/challengeDetails.dart';
import 'package:snaplify/screens/chatScreen.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/confirmDialog.dart';
import 'package:snaplify/widgets/fullphoto.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:snaplify/widgets/panorama.dart';

class ChallengeGameScreen extends StatefulWidget {
  static const routeName = '/game';
  final Challenge challenge;
  ChallengeGameScreen({Key key, @required this.challenge}) : super(key: key);
  @override
  _ChallengeGameScreenState createState() => _ChallengeGameScreenState();
}

class _ChallengeGameScreenState extends State<ChallengeGameScreen> {
  String _word = "";
  bool _isLoading = true;
  bool isFABClicked = true;
  Challenge challenge;
  FriendShipStatus status = FriendShipStatus.NoConnection;
  TextEditingController textEditingController = TextEditingController();

  bool hasError = false;

  final List<Color> _imageWidgetColor = [
    Color(0xFFd8a0ae),
    Color(0xFFc26e77),
    Color(0xFF4863A0),
    Color(0xFF008080)
  ];

  _openFullImageWidget(id) async {
    final userResponse = await showDialog(
        context: context,
        builder: (ctx) {
          return CustomConfirmDialog(
            title: "Image View Options",
            message: "",
            confirmMessage: 'NORMAL VIEW',
            denyMessage: 'PANORAMA VIEW',
          );
        });
    if (userResponse == null) return;
    if (userResponse == false) {
      Navigator.of(context).pushNamed(PanoramaWidget.routeName,
          arguments: widget.challenge.images[id]);
      return;
    } else {
      Navigator.of(context).pushNamed(FullPhoto.routeName,
          arguments: widget.challenge.images[id]);
      return;
    }
  }

  Widget _imageWidget({int id, dynamic media, Challenge challenge}) {
    return GestureDetector(
      onTap: () {
        _openFullImageWidget(id);
      },
      child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(0),
          color: _imageWidgetColor[id],
          height: media.height * 0.25,
          width: media.width * 0.45,
          child: Center(
              child: FadeInImage(
                  image: NetworkImage(widget.challenge.images[id]),
                  placeholder: AssetImage('assets/images/loadingimage.gif')))),
    );
  }

  Future<void> getFriendShipStatus() async {
    FriendShipStatus result =
        await Provider.of<FriendDataProvider>(context, listen: false)
            .getFriendshipStatus(challenge.byId);
    if (mounted)
      this.setState(() {
        status = result;
        isFABClicked = false;
      });
  }

  void _fabClickEvent() async {
    if (status == FriendShipStatus.MyFriend) {
      Users user = Users(
          uId: challenge.byId,
          name: challenge.byName,
          email: null,
          imageUrl: challenge.byImageUrl,
          points: 0);
      Navigator.of(context).pushNamed(Chat.routeName, arguments: user);
    } else if (status == FriendShipStatus.RequestPending) {
      this.setState(() {
        isFABClicked = true;
      });
      await Provider.of<FriendDataProvider>(context, listen: false)
          .responseToRequest(
              new Users(
                  uId: challenge.byId,
                  email: null,
                  name: challenge.byName,
                  imageUrl: challenge.byImageUrl,
                  points: null),
              true);
      this.setState(() {
        status = FriendShipStatus.MyFriend;
        isFABClicked = false;
      });
      Fluttertoast.showToast(
          msg: 'Challenger added to Friend List!',
          textColor: Colors.white,
          backgroundColor: Colors.purple);
    } else if (status == FriendShipStatus.RequestSent) {
      this.setState(() {
        isFABClicked = true;
      });
      await Provider.of<FriendDataProvider>(context, listen: false)
          .undoRequest(challenge.byId);
      this.setState(() {
        status = FriendShipStatus.NoConnection;
        isFABClicked = false;
      });
      Fluttertoast.showToast(
          msg: 'Removed Friend Request sent by you!',
          textColor: Colors.white,
          backgroundColor: Colors.purple);
    } else if (status == FriendShipStatus.NoConnection) {
      this.setState(() {
        isFABClicked = true;
      });
      await Provider.of<FriendDataProvider>(context, listen: false).sendRequest(
        Users(
            name: challenge.byName,
            email: "",
            uId: challenge.byId,
            imageUrl: challenge.byImageUrl),
      );
      Fluttertoast.showToast(
          msg: 'Sent Friend Request to challenger!',
          textColor: Colors.white,
          backgroundColor: Colors.purple);
      this.setState(() {
        status = FriendShipStatus.RequestSent;
        isFABClicked = false;
      });
    }
  }

  void _getHint() async {
    if (challenge.done == true) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return CustomAlertDialog(
                title: "Snap Challenge Solved!",
                message: "You have already solved the challenge!");
          });
      return;
    }
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
            confirmMessage: 'YES',
            denyMessage: 'NO',
          );
        });

    if (userResponse == null || userResponse == false) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator()));

    await Provider.of<ChallengesProvider>(context, listen: false)
        .getHints(challenge);

    Navigator.pop(context);

    Fluttertoast.showToast(
        msg: 'New Hint Unlocked!',
        textColor: Colors.white,
        backgroundColor: Colors.purple);

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
      challenge = widget.challenge;
      Provider.of<ChallengesProvider>(context, listen: false)
          .loadHints(challenge.cId, challenge.byId)
          .then((value) {
        challenge.hints = value;
        Provider.of<ChallengesProvider>(context, listen: false)
            .isDoneChallenge(challenge.cId, challenge.byId, challenge.isGlobal)
            .then((value) {
          challenge.done = value;
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        });
      });
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
    final bool _isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context, (challenge.done)),
        ),
        title: Text("Challenge"),
        actions: (_isLoading)
            ? []
            : [
                if (challenge.byId != userId)
                  IconButton(icon: Icon(Icons.help), onPressed: _getHint),
                if (challenge.byId == userId && !challenge.isGlobal)
                  IconButton(
                      icon: Icon(
                        Icons.people,
                        size: 30,
                      ),
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
                        height: media.height * 0.04,
                      )
                    : Column(children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20,
                                media.height * 0.01, 20, media.height * 0.01),
                            child: Text('Guess the Word',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ))),
                        PinCodeTextField(
                          textCapitalization: TextCapitalization.characters,
                          appContext: context,
                          backgroundColor: Colors.transparent,
                          textStyle: TextStyle(
                              color:
                                  (_isDarkMode) ? Colors.white : Colors.black),
                          length: challenge.word.length,
                          keyboardType: TextInputType.text,
                          animationType: AnimationType.fade,
                          onChanged: (value) {
                            _word = value.toLowerCase();
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.circle,
                            activeColor: Colors.purple,
                            inactiveColor: Colors.purple,
                          ),
                        ),
                      ]),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
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
                if (challenge.hints.length > 0) Center(child: Text("Hints")),
                challenge.hints.length > 0
                    ? Column(
                        children: [
                          for (var i = 0; i < challenge.hints.length; i++)
                            Padding(
                                padding:
                                    EdgeInsets.only(top: media.height * 0.005),
                                child: Text(
                                    'Letter at position ${challenge.hints[i] + 1} : ${challenge.word[challenge.hints[i]].toUpperCase()}'))
                        ],
                      )
                    : Text(""),
                challenge.hints.length > 0
                    ? SizedBox(height: media.height * 0.005)
                    : SizedBox(height: media.height * 0.02),
                (challenge.done)
                    ? Text(
                        "The word is ${challenge.word.toUpperCase()}",
                        textAlign: TextAlign.center,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 100, right: 100),
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
                                if (_word.toLowerCase() ==
                                    challenge.word.toLowerCase()) {
                                  final points =
                                      await Provider.of<ChallengesProvider>(
                                              context,
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
