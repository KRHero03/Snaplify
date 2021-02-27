import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/providers/server.dart';
import 'package:snaplify/screens/chatScreen.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/screens/profileScreen.dart';
import 'package:snaplify/widgets/requestResponseButton.dart';

// ignore: must_be_immutable
class UserGrid extends StatefulWidget {
  final Users _user;
  FriendShipStatus status;
  UserGrid(this._user, this.status);

  @override
  _UserGridState createState() => _UserGridState();
}

class _UserGridState extends State<UserGrid> {
  bool _isLoading = false;

  void onPressEventForChild(bool requestAccepted) {
    setState(() {
      if (requestAccepted)
        widget.status = FriendShipStatus.MyFriend;
      else
        widget.status = FriendShipStatus.NoConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _myId = Provider.of<Auth>(context, listen: false).userId;
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ProfileScreen.routeName,
              arguments: widget._user.uId);
        },
        child: Card(
            child: ListTile(
          leading: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    width: 35.0,
                    height: 35.0,
                    padding: EdgeInsets.all(10.0),
                  ),
                  imageUrl: widget._user.imageUrl,
                  width: 35.0,
                  height: 35.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(18.0),
                ),
                clipBehavior: Clip.hardEdge,
              )),
          title: Text(
            widget._user.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: (widget._user.points != null)
              ? Text(widget._user.points.toString() + ' Ingots')
              : null,
          trailing: _myId == widget._user.uId
              ? null
              : _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    )
                  : widget.status == FriendShipStatus.RequestPending
                      ? RequestResponseButton(
                          widget._user, onPressEventForChild)
                      : FlatButton(
                          onPressed: () async {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              if (widget.status == FriendShipStatus.MyFriend) {
                                Navigator.pushNamed(context, Chat.routeName,
                                    arguments: widget._user);
                              } else if (widget.status ==
                                  FriendShipStatus.RequestSent) {
                                await Provider.of<Server>(context,
                                        listen: false)
                                    .undoRequest(widget._user.uId, _myId);
                                widget.status = FriendShipStatus.NoConnection;
                              } else {
                                // user can follow other user
                                await Provider.of<Server>(context,
                                        listen: false)
                                    .sendRequest(widget._user.uId);
                                widget.status = FriendShipStatus.RequestSent;
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            } catch (e) {
                              await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return CustomAlertDialog(
                                      title: "Something went wrong",
                                      message: "Please check your internet",
                                    );
                                  });
                              setState(() {
                                _isLoading = false;
                              });

                              print(e);
                              throw (e);
                            }
                          },
                          child: widget.status == FriendShipStatus.MyFriend
                              ? Icon(Icons.chat, color: Colors.purple)
                              : widget.status == FriendShipStatus.RequestSent
                                  ? Icon(Icons.cancel, color: Colors.purple)
                                  : Icon(Icons.send, color: Colors.purple),
                        ),
        )));
  }
}
