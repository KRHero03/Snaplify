import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAlertDialog extends StatelessWidget {
  final String title, message;
  final bool disableButton;
  CustomAlertDialog({this.title, this.message, this.disableButton = false});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Color(0xfff3f5ff),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                this.title,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Standard',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  this.message,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Standard',
                    color: Colors.black,
                  ),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                )),
            if (!disableButton)
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, //since this is only a UI app
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        'OKAY',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Standard',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    elevation: 0,
                    minWidth: 400,
                    height: 50,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )),
          ],
        ));
  }
}
