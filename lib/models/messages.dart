import 'package:flutter/material.dart';

class Messages {
  String uId, content, time;
  Messages({@required this.uId, @required this.content, @required this.time});

  String toString() {
    return '{' + this.uId + ',' + this.content + ',' + this.time + '}';
  }
}
