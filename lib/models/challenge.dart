import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:snaplify/models/users.dart';

class Challenge {
  String cId, byId, byName, byImageUrl, word;
  DateTime dateTime;
  List<Uint8List> images = [];
  bool done, isGlobal;
  // users that have completed the challenge = doneBy, users that are left = notDoneBy
  List<Users> doneBy = [], notDoneBy = [];
  //for global Challenge
  List<int> hints = [];
  int countDone;
  Challenge(
      {@required this.cId,
      @required this.byId,
      @required this.byImageUrl,
      @required this.byName,
      @required this.dateTime,
      @required this.done,
      @required this.word,
      @required this.images,
      @required this.hints,
      this.isGlobal = false,
      this.countDone = 0,
      this.doneBy,
      this.notDoneBy});
}
