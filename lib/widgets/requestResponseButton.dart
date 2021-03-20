import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/friendship.dart';
import 'package:snaplify/widgets/alertDialog.dart';

class RequestResponseButton extends StatefulWidget {
  final Users friend;
  final onPressEvent;
  RequestResponseButton(this.friend, this.onPressEvent);

  @override
  _RequestResponseButtonState createState() => _RequestResponseButtonState();
}

class _RequestResponseButtonState extends State<RequestResponseButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Text("Respond to request"),
              SizedBox(
                height: 7,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                RaisedButton(
                    color: Colors.purple,
                    child:
                        Text("Accept", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await Provider.of<FriendDataProvider>(context,
                                listen: false)
                            .responseToRequest(widget.friend, true);
                        widget.onPressEvent(true);
                        setState(() {
                          _isLoading = false;
                        });
                      } catch (e) {
                        await showDialog(
                            context: context,
                            builder: (ctx) {
                              return CustomAlertDialog(
                                  title: "Something is wrong",
                                  message: "Try After some time");
                            });
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }),
                RaisedButton(
                    color: Colors.purple,
                    child:
                        Text("Reject", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await Provider.of<FriendDataProvider>(context,
                                listen: false)
                            .responseToRequest(widget.friend, false);
                        widget.onPressEvent(false);
                        setState(() {
                          _isLoading = false;
                        });
                      } catch (e) {
                        await showDialog(
                            context: context,
                            builder: (ctx) {
                              return CustomAlertDialog(
                                  title: "Something is wrong",
                                  message: "Try After some time");
                            });
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    })
              ]),
            ],
          );
  }
}
