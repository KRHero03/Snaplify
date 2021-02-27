import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:koukicons/add.dart';
import 'package:koukicons/substract.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/providers/server.dart';

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
    final currentUser = Provider.of<Auth>(context).userDetails;
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(),
          )
        : Container(
            width: 100,
            child: Row(children: [
              IconButton(
                  icon: Icon(Icons.add, color: Colors.purple),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<Server>(context, listen: false)
                        .responseToRequest(widget.friend, currentUser, true);
                    widget.onPressEvent(true);
                    setState(() {
                      _isLoading = false;
                    });
                  }),
              IconButton(
                  icon: Icon(Icons.cancel, color: Colors.purple),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<Server>(context, listen: false)
                        .responseToRequest(widget.friend, currentUser, false);
                    widget.onPressEvent(false);
                    setState(() {
                      _isLoading = false;
                    });
                  })
            ]),
          );
  }
}
