import 'package:animated_background/animated_background.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/profile.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/providers/friendship.dart';
import 'package:snaplify/providers/user.dart';
import 'package:snaplify/screens/chatScreen.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/challengeGrid.dart';
import 'package:snaplify/widgets/fullphoto.dart';
import 'package:snaplify/widgets/requestResponseButton.dart';
import 'package:snaplify/widgets/userGrid.dart';

class Profile extends StatefulWidget {
  final String userId;
  Profile({@required this.userId});

  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> with TickerProviderStateMixin {
  ProfileData userData;
  Users profileUser;
  bool _isLoading = true,
      _challengeloadReqPending = false,
      _challengedoneLoading = false,
      _friendloadReqPending = false,
      _frienddoneLoading = false;
  bool _isButtonClicked = false;
  String lastChallenge = "99999";
  DocumentSnapshot lastFriend;
  bool currentTabIsChallenge = true;
  FriendShipStatus status = FriendShipStatus.NoConnection;
  bool _expanded = false;
  void onPressEventForChild(bool requestAccepted) {
    setState(() {
      if (requestAccepted)
        status = FriendShipStatus.MyFriend;
      else
        status = FriendShipStatus.NoConnection;
    });
  }

  getProfileInfo() async {
    try {
      final profileUserId = widget.userId;
      final response =
          await Provider.of<UserDataProvider>(context, listen: false)
              .getProfile(profileUserId);
      if (context == null) return;
      final friendStatusResponse =
          await Provider.of<FriendDataProvider>(context, listen: false)
              .getFriendshipStatus(profileUserId);
      if (context == null) return;

      userData = response;
      status = friendStatusResponse;
      profileUser = Users(
          uId: userData.uId,
          name: userData.name,
          email: userData.email,
          imageUrl: userData.imageUrl);
      // final challengesResponse =
      //     await Provider.of<UserDataProvider>(context, listen: false)
      //         .getChallengesForProfile(profileUser, currentUser, lastChallenge);
      // if (challengesResponse.isNotEmpty)
      //   lastChallenge = challengesResponse.last.dateTime.toString();
      // userData.challengeList.addAll(challengesResponse);

      if (context == null) return;
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    } catch (e) {
      print(e);
      await showDialog(
          context: context,
          builder: (ctx) {
            return CustomAlertDialog(
                title: "Something went wrong!",
                message:
                    "Oops! Maybe the Internet broke down! Please try again after some time!");
          });
    }
  }

  @override
  void initState() {
    super.initState();
    getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId;
    final media = MediaQuery.of(context).size;
    final Users currentUser =
        Provider.of<Auth>(context, listen: false).userDetails;
    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
              baseColor: Colors.purple,
              spawnMinSpeed: 20,
              spawnMaxSpeed: 70,
              spawnMaxRadius: 30)),
      vsync: this,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.purple,
                expandedHeight: (_expanded)
                    ? kToolbarHeight + 320 + media.height * 0.15
                    : kToolbarHeight + 160 + media.height * 0.15,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [StretchMode.zoomBackground],
                  background: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                          child: GestureDetector(
                        onTap: () {
                          var url =
                              userData.imageUrl.replaceAll("s96-c", "s500-c");
                          Navigator.of(context)
                              .pushNamed(FullPhoto.routeName, arguments: url);
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.purple),
                              ),
                              width: media.height * 0.15,
                              height: media.height * 0.15,
                            ),
                            imageUrl: userData.imageUrl,
                            width: media.height * 0.15,
                            height: media.height * 0.15,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(150.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                      )),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 5, bottom: 10, left: 10, right: 10),
                        child: Center(
                          child: Text(userData.name,
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  letterSpacing: 5,
                                  fontWeight: FontWeight.bold)),
                        )),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                              child:
                                  Text("Ingots: " + userData.points.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      )),
                            ),
                            Text("Friends: " + userData.friendCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                )),
                          ],
                        )),
                    Card(
                      elevation: 2,
                      color: Colors.purple,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expanded = !_expanded;
                              });
                            },
                            child: ListTile(
                              title: Text(
                                "Stats for Nerds",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(_expanded
                                    ? Icons.expand_less
                                    : Icons.expand_more),
                                onPressed: () {
                                  setState(() {
                                    _expanded = !_expanded;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_expanded)
                            Padding(
                                padding: EdgeInsets.only(top: 7),
                                child: Center(
                                  child: Text(
                                      "Total Challenges Done: " +
                                          userData.challengesDone.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      )),
                                )),
                          if (_expanded)
                            Padding(
                                padding: EdgeInsets.only(top: 7),
                                child: Center(
                                  child: Text(
                                      "Current Solving Streak: " +
                                          userData.currentCompleteStreak
                                              .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      )),
                                )),
                          if (_expanded)
                            Padding(
                                padding: EdgeInsets.only(top: 7),
                                child: Center(
                                  child: Text(
                                      "Longest Solving Streak: " +
                                          userData.longestCompleteStreak
                                              .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      )),
                                )),
                          if (_expanded)
                            Padding(
                                padding: EdgeInsets.only(top: 7),
                                child: Center(
                                  child: Text(
                                      "Current Sending Streak: " +
                                          userData.currentSentStreak.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      )),
                                )),
                          if (_expanded)
                            Padding(
                                padding: EdgeInsets.only(top: 7, bottom: 10),
                                child: Center(
                                  child: Text(
                                      "Longest Sending Streak: " +
                                          userData.longestSentStreak.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      )),
                                )),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if ((currentTabIsChallenge &&
                          i == userData.challengeList.length + 2) ||
                      (!currentTabIsChallenge &&
                          i == userData.friends.length + 2)) {
                    if (currentTabIsChallenge) {
                      if (_challengedoneLoading) {
                        if (userData.challengeList.isEmpty)
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("No Challenges Found")),
                          );
                        return null;
                      }
                      if (!_challengeloadReqPending) {
                        _challengeloadReqPending = true;
                        Provider.of<UserDataProvider>(context, listen: false)
                            .getChallengesForProfile(
                                profileUser, currentUser, lastChallenge)
                            .then((value) {
                          if (value.isEmpty) _challengedoneLoading = true;
                          userData.challengeList.addAll(value);
                          if (userData.challengeList.isNotEmpty)
                            lastChallenge =
                                userData.challengeList.last.dateTime.toString();
                          if (mounted) setState(() {});
                          _challengeloadReqPending = false;
                        });
                      }
                    } else {
                      if (_frienddoneLoading) {
                        if (userData.friends.isEmpty)
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("No friends Found")),
                          );
                        return null;
                      }
                      if (!_friendloadReqPending) {
                        _friendloadReqPending = true;
                        Provider.of<FriendDataProvider>(context, listen: false)
                            .getFriendsList(profileUser.uId, lastFriend)
                            .then((value) {
                          if (value["data"].isEmpty) _frienddoneLoading = true;
                          userData.friends.addAll(value["data"]);
                          lastFriend = value["last"];
                          if (mounted) setState(() {});
                          _friendloadReqPending = false;
                        });
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (i == 0) {
                    return Column(children: [
                      status == FriendShipStatus.MyFriend
                          ? Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: RaisedButton(
                                      color: Colors.purple,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, Chat.routeName,
                                            arguments: Users(
                                                email: userData.email,
                                                name: userData.name,
                                                imageUrl: userData.imageUrl,
                                                points: userData.points,
                                                uId: userData.uId));
                                      },
                                      child: Text(
                                        'CHAT',
                                        style: TextStyle(color: Colors.white),
                                      ))))
                          : Text(''),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                              child: _isButtonClicked
                                  ? CircularProgressIndicator()
                                  : userId == currentUser.uId
                                      ? RaisedButton(
                                          color: Colors.purple,
                                          onPressed: () async {
                                            this.setState(() {
                                              _isButtonClicked = true;
                                            });
                                            Navigator.of(context).popUntil(
                                                ModalRoute.withName("/"));
                                            await Provider.of<Auth>(context,
                                                    listen: false)
                                                .signOutGoogle();
                                            this.setState(() {
                                              _isButtonClicked = false;
                                            });
                                          },
                                          child: Text('LOGOUT',
                                              style: TextStyle(
                                                  color: Colors.white)))
                                      : status ==
                                              FriendShipStatus.RequestPending
                                          ? RequestResponseButton(
                                              new Users(
                                                  uId: userId,
                                                  name: userData.name,
                                                  email: userData.email,
                                                  imageUrl: userData.imageUrl,
                                                  points: userData.points),
                                              onPressEventForChild)
                                          : status ==
                                                  FriendShipStatus.NoConnection
                                              ? RaisedButton(
                                                  color: Colors.purple,
                                                  onPressed: () async {
                                                    this.setState(() {
                                                      _isButtonClicked = true;
                                                    });
                                                    try {
                                                      await Provider.of<
                                                                  FriendDataProvider>(
                                                              context,
                                                              listen: false)
                                                          .sendRequest(
                                                              profileUser);
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'Sent Friend Request to challenger!',
                                                          textColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              Colors.purple);
                                                      this.setState(() {
                                                        status =
                                                            FriendShipStatus
                                                                .RequestSent;
                                                        _isButtonClicked =
                                                            false;
                                                      });
                                                    } catch (e) {
                                                      await showDialog(
                                                          context: context,
                                                          builder: (ctx) {
                                                            return CustomAlertDialog(
                                                                title:
                                                                    "Something went wrong!",
                                                                message:
                                                                    "Try again after some time.");
                                                          });
                                                      setState(() {
                                                        _isButtonClicked =
                                                            false;
                                                      });
                                                    }
                                                  },
                                                  child: Text('ADD AS FRIEND',
                                                      style: TextStyle(
                                                          color: Colors.white)))
                                              : status ==
                                                      FriendShipStatus
                                                          .RequestSent
                                                  ? RaisedButton(
                                                      color: Colors.purple,
                                                      onPressed: () async {
                                                        this.setState(() {
                                                          _isButtonClicked =
                                                              true;
                                                        });
                                                        try {
                                                          await Provider.of<
                                                                      FriendDataProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .undoRequest(
                                                                  userId);
                                                          this.setState(() {
                                                            status =
                                                                FriendShipStatus
                                                                    .NoConnection;
                                                            _isButtonClicked =
                                                                false;
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'Removed Friend Request sent by you!',
                                                              textColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors
                                                                      .purple);
                                                        } catch (e) {
                                                          await showDialog(
                                                              context: context,
                                                              builder: (ctx) {
                                                                return CustomAlertDialog(
                                                                    title:
                                                                        "Something is wrong",
                                                                    message:
                                                                        "Try After some time");
                                                              });
                                                          setState(() {
                                                            _isButtonClicked =
                                                                false;
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                          'CANCEL REQUEST',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)))
                                                  : status ==
                                                          FriendShipStatus
                                                              .MyFriend
                                                      ? RaisedButton(
                                                          color: Colors.purple,
                                                          onPressed: () async {
                                                            this.setState(() {
                                                              _isButtonClicked =
                                                                  true;
                                                            });
                                                            try {
                                                              await Provider.of<
                                                                          FriendDataProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .removeFriend(
                                                                Users(
                                                                    uId: userData
                                                                        .uId,
                                                                    name: userData
                                                                        .name,
                                                                    email: userData
                                                                        .email,
                                                                    imageUrl:
                                                                        userData
                                                                            .imageUrl),
                                                              );
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      'Removed User as Friend!',
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .purple);
                                                              this.setState(() {
                                                                status =
                                                                    FriendShipStatus
                                                                        .NoConnection;
                                                                _isButtonClicked =
                                                                    false;
                                                              });
                                                            } catch (e) {
                                                              await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (ctx) {
                                                                    return CustomAlertDialog(
                                                                        title:
                                                                            "Something is wrong",
                                                                        message:
                                                                            "Try After some time");
                                                                  });
                                                              setState(() {
                                                                _isButtonClicked =
                                                                    false;
                                                              });
                                                            }
                                                          },
                                                          child: Text(
                                                              'REMOVE AS FRIEND',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)))
                                                      : null))
                    ]);
                  }
                  if (i == 1)
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                              color: (!currentTabIsChallenge)
                                  ? Colors.grey
                                  : Colors.purple,
                              onPressed: () {
                                setState(() {
                                  currentTabIsChallenge = true;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      bottomLeft: Radius.circular(30))),
                              child: Text("Challenges",
                                  style: TextStyle(color: Colors.white))),
                          RaisedButton(
                              color: (currentTabIsChallenge)
                                  ? Colors.grey
                                  : Colors.purple,
                              onPressed: () {
                                setState(() {
                                  currentTabIsChallenge = false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      bottomRight: Radius.circular(30))),
                              child: Text("  Friends  ",
                                  style: TextStyle(color: Colors.white)))
                        ],
                      ),
                    );
                  if (currentTabIsChallenge)
                    return ChallengeGrid(userData.challengeList[i - 2]);
                  else
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: UserGrid(
                        userData.friends[i - 2],
                        status: FriendShipStatus.MyFriend,
                        disableButton:
                            (currentUser.uId == userId) ? false : true,
                      ),
                    );
                },
                childCount: (currentTabIsChallenge)
                    ? userData.challengeList.length + 3
                    : userData.friends.length + 3,
              ))
            ]),
    );
  }
}
