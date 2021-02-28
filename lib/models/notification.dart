import 'package:flutter/material.dart';

enum NotificationType {
  FriendRequest,
  ChallengeDone,
  Bonus,
  FriendRequestAccepted,
}

class FriendRequestNotification {
  final String byId;
  final bool seen;
  final DateTime dateTime;
  final String imageUrl;
  final String byName;
  FriendRequestNotification(
      {@required this.byId,
      @required this.byName,
      @required this.imageUrl,
      @required this.dateTime,
      @required this.seen});
}

class FriendRequestAcceptedNotification {
  final String byId;
  final String imageUrl;
  final bool seen;
  final DateTime dateTime;
  final String byName;
  FriendRequestAcceptedNotification(
      {@required this.byId,
      @required this.byName,
      @required this.imageUrl,
      @required this.dateTime,
      @required this.seen});
}

class ChallengeDoneNotification {
  final String byId;
  final String imageUrl;
  final String byName;
  final String word;
  final bool seen;
  final DateTime dateTime;
  final int hintCount;
  ChallengeDoneNotification(
      {@required this.byId,
      @required this.byName,
      @required this.imageUrl,
      @required this.hintCount,
      @required this.word,
      @required this.dateTime,
      @required this.seen});
}

class BonusNotification {
  final int points;
  final int days;
  final bool seen;
  final DateTime dateTime;
  //streakType can be "creating challenges" or "completing challenges"
  final String streakType;
  BonusNotification(
      {@required this.days,
      @required this.points,
      @required this.streakType,
      @required this.dateTime,
      @required this.seen});
}
