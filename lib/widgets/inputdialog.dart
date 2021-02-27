import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _word = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter the word'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          validator: (word) {
            if (word.isEmpty) return "Word can't be empty";
            if (word.contains(" ")) return "Word can't contain any space";
            RegExp _alpha = RegExp(r'^[a-zA-Z]+$');
            if (!_alpha.hasMatch(word))
              return "All the charaters must be alphabets";
            if (word.length > 20) return "Word can't be greater than 20";
            return null;
          },
          onChanged: (value) {
            _word = value;
          },
          decoration: InputDecoration(hintText: "Word"),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Next',
            style: TextStyle(
                fontFamily: 'OpenSans', color: Theme.of(context).primaryColor),
          ),
          onPressed: () async {
            if (!_formKey.currentState.validate()) return;

            Navigator.of(context).pop(_word);
          },
        )
      ],
    );
  }
}
