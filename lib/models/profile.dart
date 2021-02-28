import 'package:flutter/material.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/friendShipStatus.dart';

class ProfileData {
  String uId, name, email, imageUrl;
  int points, friendCount, challengesDone;
  int currentCompleteStreak,
      longestCompleteStreak,
      currentSentStreak,
      longestSentStreak;
  FriendShipStatus friendShipStatus;
  var challengeList = new List<Challenge>();
  ProfileData(
      {@required this.uId,
      @required this.name,
      @required this.email,
      @required this.imageUrl,
      @required this.points,
      @required this.friendCount,
      @required this.challengesDone,
      @required this.challengeList,
      @required this.currentCompleteStreak,
      @required this.currentSentStreak,
      @required this.longestCompleteStreak,
      @required this.longestSentStreak,
      @required this.friendShipStatus});
}
