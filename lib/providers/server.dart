import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/profile.dart';
import 'package:snaplify/models/users.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class Server with ChangeNotifier {
  String userId;
  Server(this.userId);
  final databaseReference = FirebaseFirestore.instance;

  /*
  ************************************
  User Data Section
  ************************************
  */

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
    print(profileId);
    try {
      final response =
          await databaseReference.collection("Users").doc(profileId).get();
      final data = response.data();
      final uId = profileId;
      final name = data['name'];
      final email = data['email'];
      final imageUrl = data['imageUrl'];
      final points = data['points'] != null ? data['points'] : 0;
      final friendCount =
          data['friends'] == null ? 0 : data['friends'].toList().length;
      final challengeDone = data['challengeDone'];

      FriendShipStatus friendShipStatus = FriendShipStatus.NoConnection;
      response.data()["friends"].toList().forEach((user) {
        if (user["friendId"] == userId)
          friendShipStatus = FriendShipStatus.MyFriend;
      });
      response.data()["requestsSent"].toList().forEach((id) {
        if (id == userId) friendShipStatus = FriendShipStatus.RequestSent;
      });
      response.data()["requests"].toList().forEach((id) {
        if (id == userId) friendShipStatus = FriendShipStatus.RequestPending;
      });

      final streakResponse =
          await databaseReference.collection("streak").doc(profileId).get();

      final streakData = streakResponse.data();
      var completeStreakCount = 0;
      var sentStreakCount = 0;
      var longestCompleteStreakCount = 0;
      var longestSentStreakCount = 0;
      if (streakData != null) {
        completeStreakCount = streakData['completeStreakCount'] == null
            ? 0
            : streakData['completeStreakCount'];
        sentStreakCount = streakData['sentStreakCount'] == null
            ? 0
            : streakData['sentStreakCount'];
        longestCompleteStreakCount =
            streakData['longestCompleteStreakCount'] == null
                ? 0
                : streakData['longestCompleteStreakCount'];
        longestSentStreakCount = streakData['longestSentStreakCount'] == null
            ? 0
            : streakData['longestSentStreakCount'];
      }
      Map<String, List<int>> hints = await loadHints();
      List challengeList = new List<Challenge>();
      final challengeResponse = await databaseReference
          .collection('Users')
          .doc(profileId)
          .collection("byMe")
          .get();

      challengeResponse.docs.forEach((element) {
        bool done = false;
        bool canAccess = false;
        if (userId != profileId) {
          if (element.data()["shared"].isEmpty) {
            canAccess = true;
          }
          element.data()["shared"].forEach((userCompleted) {
            if (userCompleted["uId"] == userId) canAccess = true;
          });
          if (element.data()["sharedDone"] != null)
            element.data()["sharedDone"].forEach((userCompleted) {
              if (userCompleted["uId"] == userId) done = true;
            });
        } else {
          done = true;
          canAccess = true;
        }
        if (canAccess) {
          challengeList.add(
            new Challenge(
                cId: element.id,
                byId: userId,
                byImageUrl: imageUrl,
                byName: name,
                word: element.data()['word'],
                dateTime: DateTime.parse(element.data()['dateTime']),
                done: done,
                isGlobal: element.data()["shared"].length == 0 ? true : false,
                images: [null, null, null, null],
                hints: hints.containsKey(element.id) ? hints[element.id] : []),
          );
        }
      });

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
          challengeList: challengeList,
          friendShipStatus: friendShipStatus);

      return result;
    } catch (e) {
      print(e);
      throw e;
    }
  }


