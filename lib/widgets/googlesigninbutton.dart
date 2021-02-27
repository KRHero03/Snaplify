import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/widgets/alertDialog.dart';

// ignore: camel_case_types
class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

// ignore: camel_case_types
class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : OutlineButton(
            splashColor: Colors.grey,
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<Auth>(context, listen: false)
                    .signInWithGoogle();
              } catch (e) {
                await showDialog(
                    context: context,
                    builder: (_) => CustomAlertDialog(
                          title: "Something went worng",
                          message: "Please check your internet",
                        ));
              }
              setState(() {
                _isLoading = false;
              });
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.grey),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                      image: AssetImage("assets/images/google_logo.png"),
                      height: 35.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
