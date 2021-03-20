import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/profile.dart';
import 'package:snaplify/models/users.dart';
import 'package:flutter/widgets.dart';

class UserDataProvider with ChangeNotifier {
  final String userId;
  UserDataProvider(this.userId);
  final databaseReference = FirebaseFirestore.instance;
  Future<Users> getUserWithUserId(userId) async {
    try {
      final response =
          await databaseReference.collection("Users").doc(userId).get();
      final data = response.data();
      Users userObject = new Users(
          uId: userId,
          name: data['name'],
          email: data['email'],
          imageUrl: data['imageUrl'],
          points: data['points'] != null ? data['points'] : 0);
      return userObject;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<ProfileData> getProfile(profileId) async {
    try {
      final response =
          await databaseReference.collection("Users").doc(profileId).get();
      final data = response.data();
      final uId = profileId;
      final name = data['name'];
      final email = data['email'];
      final imageUrl = data['imageUrl'];
      final points = data['points'] != null ? data['points'] : 0;
      final challengeDone = data['challengeDone'];

      final friendCount = data['friendsCount'];

      var completeStreakCount = 0;
      var sentStreakCount = 0;
      var longestCompleteStreakCount = 0;
      var longestSentStreakCount = 0;
      completeStreakCount = data['completeStreakCount'];
      sentStreakCount = data['sentStreakCount'];
      longestCompleteStreakCount = data['longestCompleteStreakCount'];
      longestSentStreakCount = data['longestSentStreakCount'];
      ProfileData result = new ProfileData(
          uId: uId,
          name: name,
          email: email,
          imageUrl: imageUrl,
          points: points,
          friendCount: friendCount,
          currentCompleteStreak: completeStreakCount,
          longestCompleteStreak: longestCompleteStreakCount,
          currentSentStreak: sentStreakCount,
          longestSentStreak: longestSentStreakCount,
          challengesDone: challengeDone,
          challengeList: [],
          friends: [],
          friendShipStatus: null);

      return result;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<Challenge>> getChallengesForProfile(
      Users profile, Users currentUser, String last) async {
    try {
      if (profile.uId == currentUser.uId) {
        final response = await databaseReference
            .collection("Users")
            .doc(profile.uId)
            .collection("byMe")
            .orderBy("dateTime", descending: true)
            .where("dateTime", isLessThan: last)
            .limit(2)
            .get();

        List<Challenge> challenges = [];
        response.docs.forEach((element) {
          bool isGlobal = false;
          if (element.data()["shared"].isNotEmpty &&
              element.data()["shared"][0]["uId"] == profile.uId)
            isGlobal = true;

          challenges.add(Challenge(
              cId: element.id,
              byId: profile.uId,
              byImageUrl: profile.imageUrl,
              byName: profile.name,
              dateTime: DateTime.parse(element.data()["dateTime"]),
              done: true,
              word: element.data()["word"],
              isGlobal: isGlobal,
              images: element.data()["images"].cast<String>()));
        });

        return challenges;
      } else {
        final response = await databaseReference
            .collection("Users")
            .doc(profile.uId)
            .collection("byMe")
            .orderBy("dateTime", descending: true)
            .where("dateTime", isLessThan: last)
            .where("shared", arrayContainsAny: [
              {
                "uId": profile.uId,
                "name": profile.name,
                "imageUrl": profile.imageUrl,
              },
              {
                "uId": currentUser.uId,
                "name": currentUser.name,
                "imageUrl": currentUser.imageUrl,
              }
            ])
            .limit(1)
            .get();

        List<Challenge> challenges = [];
        response.docs.forEach((element) {
          bool isGlobal = false;
          if (element.data()["shared"].isNotEmpty &&
              element.data()["shared"][0]["uId"] == profile.uId)
            isGlobal = true;

          challenges.add(Challenge(
              cId: element.id,
              byId: profile.uId,
              byImageUrl: profile.imageUrl,
              byName: profile.name,
              dateTime: DateTime.parse(element.data()["dateTime"]),
              done: false, //update when challenge page is loaded
              word: element.data()["word"],
              isGlobal: isGlobal,
              images: element.data()["images"].cast<String>()));
        });
        return challenges;
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }
}
