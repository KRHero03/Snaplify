import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/offensivewords.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/providers/server.dart';
import 'package:snaplify/widgets/alertDialog.dart';

class ShareChallenge extends StatefulWidget {
  static const routeName = '/share';
  @override
  _ShareChallengeState createState() => _ShareChallengeState();
}

class _ShareChallengeState extends State<ShareChallenge> {
  List<bool> _response = [];
  List<Users> _friends;
  bool _isLoading = true;
  final int points = 20;
  @override
  void initState() {
    Provider.of<Server>(context, listen: false).getFriends().then((value) {
      _friends = value;
      for (int i = 0; i < _friends.length + 3; ++i) _response.add(false);
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  void sendGlobally() {
    _response[0] = !_response[0];
    _response.fillRange(0, _response.length, _response[0]);
  }

  void sendToAllFriends() {
    _response[0] = false;
    _response[1] = !_response[1];
    _response.fillRange(1, _response.length, _response[1]);
  }

  @override
  Widget build(BuildContext context) {
    Users currentUser = Provider.of<Auth>(context, listen: false).userDetails;
    final data =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    String word = data["word"];
    List<File> images = data["images"];
    return Scaffold(
      appBar: AppBar(title: Text("Send to")),
      body: (_isLoading)
          ? Center(child: CircularProgressIndicator())
          : (_friends.isEmpty)
              ? Card(
                  child: CheckboxListTile(
                    title: Text("Send Globally"),
                    value: _response[0],
                    onChanged: (newValue) {
                      setState(() {
                        sendGlobally();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                )
              : ListView.builder(
                  itemCount: _friends.length + 3,
                  itemBuilder: (cxt, i) {
                    if (i == 0)
                      return Card(
                        child: CheckboxListTile(
                          title: Text("Send Globally"),
                          value: _response[i],
                          onChanged: (newValue) {
                            setState(() {
                              sendGlobally();
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      );
                    if (i == 1)
                      return Card(
                        child: CheckboxListTile(
                          title: Text("Send to all friends"),
                          value: _response[i],
                          onChanged: (newValue) {
                            setState(() {
                              sendToAllFriends();
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      );
                    if (i == 2)
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 5, bottom: 3),
                        child: Text("Send only to"),
                      );
                    return Card(
                      margin: const EdgeInsets.all(5),
                      child: CheckboxListTile(
                        title: ListTile(
                          leading: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.purple),
                                ),
                                width: 35.0,
                                height: 35.0,
                                padding: EdgeInsets.all(10.0),
                              ),
                              imageUrl: _friends[i - 3].imageUrl,
                              width: 35.0,
                              height: 35.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(18.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          title: Text(_friends[i - 3].name),
                        ),
                        value: _response[i],
                        onChanged: (newValue) {
                          setState(() {
                            _response[i] = !_response[i];
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    );
                  }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            if (!_response.contains(true)) return null;
            setState(() {
              _isLoading = true;
            });
            // final valid = await Provider.of<Server>(context, listen: false)
            //     .checkImageSafety(images);
            // if (!valid) {
            //   await showDialog(
            //       context: context,
            //       builder: (ctx) {
            //         return CustomAlertDialog(
            //             title: "Inappropriate Image",
            //             message:
            //                 "You have used one or more Inappropriate Images! Please modify your image(s).");
            //       });
            //   setState(() {
            //     _isLoading = false;
            //   });
            //   return;
            // }
            bool isOffensiveWordFound = false;
            OFFENSIVE_WORDS.forEach((element) {
              if (word.contains(element)) isOffensiveWordFound = true;
            });
            if (isOffensiveWordFound) {
              await showDialog(
                  context: context,
                  builder: (ctx) {
                    return CustomAlertDialog(
                        title: "Inappropriate Word",
                        message:
                            "You have used an Inappropriate word! Please modify your word!");
                  });
              setState(() {
                _isLoading = false;
              });
              return;
            }
            List<Users> to = [];
            if (_response[0]) {
              await Provider.of<Server>(context, listen: false).sendChallenge(
                  to, currentUser, word, images, points,
                  sendGlobally: true);
            } else {
              for (int i = 0; i < _friends.length; ++i)
                if (_response[i + 3]) to.add(_friends[i]);
              await Provider.of<Server>(context, listen: false)
                  .sendChallenge(to, currentUser, word, images, points);
            }
            Navigator.popUntil(context, ModalRoute.withName('/'));
            await showDialog(
                context: context,
                builder: (ctx) {
                  return CustomAlertDialog(
                      title: "Challenge Sent",
                      message: "You have been rewarded with $points Ingots");
                });
          } catch (e) {
            await showDialog(
                context: context,
                builder: (ctx) {
                  return CustomAlertDialog(
                      title: "Something went wrong",
                      message: "Please check your network");
                });
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
