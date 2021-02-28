import 'package:flutter/material.dart';

class Users {
  String uId, name, email, imageUrl;
  int points;
  Users(
      {@required this.uId,
      @required this.name,
      @required this.email,
      @required this.imageUrl,
      this.points});

  String toString() {
    return '{' +
        this.uId +
        ',' +
        this.name +
        ',' +
        this.email +
        ',' +
        this.imageUrl +
        ',' +
        this.points.toString() +
        '}';
  }
}
