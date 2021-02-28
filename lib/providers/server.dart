import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:snaplify/models/friendShipStatus.dart';
import 'package:snaplify/models/notification.dart';
import 'package:snaplify/models/profile.dart';
import 'package:snaplify/models/users.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class Server with ChangeNotifier {
  final String userId;
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

      FriendShipStatus friendShipStatus =
          await getFriendshipStatus(userId, profileId);
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

  /*
  **********************************
  FriendShip and Request Section
  **********************************
  */

  Future<List<Users>> getFriends() async {
    try {
      final response =
          await databaseReference.collection("Users").doc(userId).get();
      List<Users> friends = [];
      response.data()["friends"].toList().forEach((user) {
        friends.add(Users(
            uId: user["friendId"],
            name: user["name"],
            email: user["email"],
            imageUrl: user["imageUrl"],
            points: user["points"] != null ? user["points"] : 0));
      });

      return friends;
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<FriendShipStatus> getFriendshipStatus(userId, peerId) async {
    try {
      final response =
          await databaseReference.collection("Users").doc(userId).get();
      FriendShipStatus result = FriendShipStatus.NoConnection;
      response.data()["friends"].toList().forEach((user) {
        if (user["friendId"] == peerId) result = FriendShipStatus.MyFriend;
      });
      response.data()["requestsSent"].toList().forEach((id) {
        if (id == peerId) result = FriendShipStatus.RequestSent;
      });
      response.data()["requests"].toList().forEach((id) {
        if (id == peerId) result = FriendShipStatus.RequestPending;
      });

      return result;
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<List<Users>> getFriendsWithPoints() async {
    try {
      List<Users> friends = await getFriends();
      for (int i = 0; i < friends.length; ++i) {
        final response = await databaseReference
            .collection("Users")
            .doc(friends[i].uId)
            .get();
        friends[i].points = response.data()["points"];
      }
      return friends;
    } catch (e) {
      throw (e);
    }
  }

  Future<Map<String, List<Users>>> getFriendsRequestData() async {
    try {
      final response =
          await databaseReference.collection("Users").doc(userId).get();
      Map<String, List<Users>> data = new Map<String, List<Users>>();
      data["friends"] = [];
      data["requestsSent"] = [];
      data["requests"] = [];
      response.data()["friends"].toList().forEach((user) {
        data["friends"].add(Users(
            uId: user["friendId"],
            name: user["name"],
            email: user["email"],
            imageUrl: user["imageUrl"],
            points: user["points"]));
      });
      response.data()["requestsSent"].toList().forEach((user) {
        data["requestsSent"].add(Users(
            uId: user, name: null, email: null, imageUrl: null, points: null));
      });

      response.data()["requests"].toList().forEach((user) {
        data["requests"].add(Users(
            uId: user, name: null, email: null, imageUrl: null, points: null));
      });
      return data;
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<void> sendRequest(String friendId, Users currentUser) async {
    try {
      final DateTime dateTime = DateTime.now();

      await Future.wait([
        databaseReference.collection("Users").doc(friendId).update({
          "requests": FieldValue.arrayUnion([userId])
        }),
        databaseReference.collection("Users").doc(userId).update({
          "requestsSent": FieldValue.arrayUnion([friendId])
        }),
        databaseReference.collection("notification").doc(friendId).update({
          "data": FieldValue.arrayUnion([
            {
              "type": NotificationType.FriendRequest.toString(),
              "seen": false,
              "dateTime": dateTime.toString(),
              "byId": userId,
              "imageUrl": currentUser.imageUrl,
              "byName": currentUser.name,
            }
          ])
        }),
      ]);
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<void> undoRequest(String to, String from) async {
    try {
      await Future.wait([
        databaseReference.collection("Users").doc(to).update({
          "requests": FieldValue.arrayRemove([from])
        }),
        databaseReference.collection("Users").doc(from).update({
          "requestsSent": FieldValue.arrayRemove([to])
        })
      ]);
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<void> removeFriend(Users friend, Users me) async {
    try {
      await Future.wait([
        databaseReference.collection("Users").doc(me.uId).update({
          "friends": FieldValue.arrayRemove([
            {
              "email": friend.email,
              "friendId": friend.uId,
              "imageUrl": friend.imageUrl,
              "name": friend.name
            }
          ])
        }),
        databaseReference.collection("Users").doc(friend.uId).update({
          "friends": FieldValue.arrayRemove([
            {
              "email": me.email,
              "friendId": me.uId,
              "imageUrl": me.imageUrl,
              "name": me.name
            }
          ])
        }),
      ]);
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<void> responseToRequest(
      Users friend, Users currentUser, bool response) async {
    try {
      final DateTime dateTime = DateTime.now();
      if (response) {
        //accept the request
        await Future.wait([
          undoRequest(currentUser.uId, friend.uId),
          databaseReference.collection("Users").doc(friend.uId).update({
            "friends": FieldValue.arrayUnion([
              {
                "name": currentUser.name,
                "friendId": currentUser.uId,
                "imageUrl": currentUser.imageUrl,
                "email": currentUser.email,
              }
            ])
          }),
          databaseReference.collection("Users").doc(userId).update({
            "friends": FieldValue.arrayUnion([
              {
                "name": friend.name,
                "friendId": friend.uId,
                "imageUrl": friend.imageUrl,
                "email": friend.email,
              }
            ])
          }),
          databaseReference.collection("notification").doc(friend.uId).update({
            "data": FieldValue.arrayUnion([
              {
                "type": NotificationType.FriendRequestAccepted.toString(),
                "dateTime": dateTime.toString(),
                "seen": false,
                "byId": userId,
                "imageUrl": currentUser.imageUrl,
                "byName": currentUser.name,
              }
            ])
          }),
        ]);
      } else {
        //reject the request
        await undoRequest(currentUser.uId, friend.uId);
      }
    } catch (e) {
      throw (e);
    }
  }

  /*
  ************************************
  Streak Section
  ************************************
  */

  // return bonus points rewarded
  Future<int> streakForSend() async {
    try {
      final DateTime dateTime = DateTime.now();
      final int streakLengthForReward = 7;
      final int streakBonus = 50;
      DateTime currentDateTime = DateTime.now();
      int bonus = 0;
      final response =
          await databaseReference.collection("streak").doc(userId).get();

      if (response.data() != null &&
          response.data()["sentStreakCount"] != null) {
        int sentStreakCount = response.data()["sentStreakCount"];
        int longestSentStreakCount = response.data()["longestSentStreakCount"];
        DateTime lastSentTimestamp =
            DateTime.parse(response.data()["lastSentTimestamp"]);

        if (currentDateTime.difference(lastSentTimestamp) >
            Duration(hours: 48)) {
          // streak has been break
          sentStreakCount = 1;
        } else if (currentDateTime.difference(lastSentTimestamp) >=
            Duration(hours: 24)) {
          sentStreakCount++;
          longestSentStreakCount = max(longestSentStreakCount, sentStreakCount);
        }

        if (sentStreakCount % streakLengthForReward == 0) bonus += streakBonus;

        await Future.wait([
          databaseReference.collection("streak").doc(userId).update({
            "sentStreakCount": sentStreakCount,
            "longestSentStreakCount": longestSentStreakCount,
            "lastSentTimestamp": currentDateTime.toString(),
          }),
          if (bonus > 0)
            databaseReference.collection("notification").doc(userId).update({
              "data": FieldValue.arrayUnion([
                {
                  "type": NotificationType.Bonus.toString(),
                  "points": bonus,
                  "seen": false,
                  "days": streakLengthForReward,
                  "streakType": "creating challenges",
                  "dateTime": dateTime.toString(),
                }
              ])
            })
        ]);
      } else {
        await databaseReference.collection("streak").doc(userId).set({
          "sentStreakCount": 1,
          "longestSentStreakCount": 1,
          "lastSentTimestamp": currentDateTime.toString(),
        }, SetOptions(merge: true));
      }

      return bonus;
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<int> streakForComplete() async {
    try {
      final DateTime dateTime = DateTime.now();
      final int streakLengthForReward = 7;
      final int streakBonus = 50;
      DateTime currentDateTime = DateTime.now();
      int bonus = 0;
      print(userId);
      final response =
          await databaseReference.collection("streak").doc(userId).get();

      if (response.data() != null &&
          response.data()["completeStreakCount"] != null) {
        int completeStreakCount = response.data()["completeStreakCount"];
        int longestCompleteStreakCount =
            response.data()["longestCompleteStreakCount"];
        DateTime lastCompleteTimestamp =
            DateTime.parse(response.data()["lastCompleteTimestamp"]);

        if (currentDateTime.difference(lastCompleteTimestamp) >
            Duration(hours: 48)) {
          // streak has been break
          completeStreakCount = 1;
        } else if (currentDateTime.difference(lastCompleteTimestamp) >=
            Duration(hours: 24)) {
          completeStreakCount++;
          longestCompleteStreakCount =
              max(longestCompleteStreakCount, completeStreakCount);
        }

        if (completeStreakCount % streakLengthForReward == 0)
          bonus += streakBonus;

        await Future.wait([
          databaseReference.collection("streak").doc(userId).update({
            "completeStreakCount": completeStreakCount,
            "longestCompleteStreakCount": longestCompleteStreakCount,
            "lastCompleteTimestamp": currentDateTime.toString(),
          }),
          if (bonus > 0)
            databaseReference.collection("notification").doc(userId).update({
              "data": FieldValue.arrayUnion([
                {
                  "type": NotificationType.Bonus.toString(),
                  "points": bonus,
                  "seen": false,
                  "days": streakLengthForReward,
                  "streakType": "completing challenges",
                  "dateTime": dateTime.toString(),
                }
              ])
            })
        ]);
      } else {
        await databaseReference.collection("streak").doc(userId).set({
          "completeStreakCount": 1,
          "longestCompleteStreakCount": 1,
          "lastCompleteTimestamp": currentDateTime.toString(),
        }, SetOptions(merge: true));
      }
      return bonus;
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  /*
  ************************************
  Hints Section
  ************************************
  */
  Future<Map<String, List<int>>> loadHints() async {
    try {
      final response = await databaseReference
          .collection("Users")
          .doc(userId)
          .collection("hints")
          .get();
      Map<String, List<int>> hints = new Map<String, List<int>>();
      response.docs.forEach((hint) {
        hints[hint.id] = hint.data()["hints"].cast<int>();
      });
      return hints;
    } catch (e) {
      throw (e);
    }
  }

  Future<int> getHints(Challenge challenge) async {
    Random rand = Random();
    int random = -1;
    while (random == -1) {
      random = rand.nextInt(challenge.word.length);
      if (challenge.hints.contains(random)) random = -1;
    }
    var hints = challenge.hints;
    hints.add(random);
    try {
      await databaseReference
          .collection("Users")
          .doc(userId)
          .collection("hints")
          .doc(challenge.cId)
          .set({"dateTime": challenge.dateTime.toString(), "hints": hints});
      return random;
    } catch (e) {
      throw (e);
    }
  }

  /*
  ************************************
  Challenge Section
  ************************************
  */

  Future<bool> checkImageSafety(List<File> images) async {
    final url = 'https://snaplify.herokuapp.com/api/classify/image/';
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
      'DNT': '1',
      'Content-Type': 'text/plain;charset=UTF-8',
      'Accept': '/'
    };
    try {
      for (int i = 0; i < 4; ++i) {
        var request = http.MultipartRequest('GET', Uri.parse(url));
        request.files
            .add(await http.MultipartFile.fromPath('image', images[i].path));
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          final res = await response.stream.bytesToString();
          final decoded = json.decode(res);
          if (decoded["result"] != "safe") return false;
        } else {
          print(response.reasonPhrase);
          throw (response.reasonPhrase);
        }
      }
      return true;
    } catch (e) {
      throw (e);
    }
  }

  Future<void> sendChallenge(
      List<Users> to, Users from, String word, List<File> images, int points,
      {bool sendGlobally = false}) async {
    try {
      final dateTime = DateTime.now().toString();
      var sharedTo = [];
      if (!sendGlobally)
        to.forEach((element) {
          sharedTo.add({
            "uId": element.uId,
            "name": element.name,
            "imageUrl": element.imageUrl,
          });
        });
      final saved = await databaseReference
          .collection("Users")
          .doc(from.uId)
          .collection("byMe")
          .add({
        "word": word,
        "dateTime": dateTime.toString(),
        "shared": sharedTo.toList(),
      });
      // checking streak
      points += await streakForSend();
      await Future.wait([
        moiBitUpload(images, saved.id),
        databaseReference
            .collection("Users")
            .doc(from.uId)
            .update({"points": FieldValue.increment(points)})
      ]);
      if (sendGlobally) {
        await databaseReference.collection("global").doc(saved.id).set({
          "word": word,
          "count": 0,
          "byUid": from.uId,
          "byName": from.name,
          "byImageUrl": from.imageUrl,
          "dateTime": dateTime
        });
      } else {
        for (int i = 0; i < to.length; ++i) {
          final element = to[i];
          await databaseReference
              .collection("Users")
              .doc(element.uId)
              .collection("challenges")
              .doc(saved.id)
              .set({
            "word": word,
            "done": false,
            "byUid": from.uId,
            "byName": from.name,
            "byImageUrl": from.imageUrl,
            "dateTime": dateTime,
          });
        }
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<void> moiBitUpload(List<File> images, String id) async {
    try {
      final url = 'https://kfs4.moibit.io/moibit/v0/writefile';
      Dio dio = new Dio();

      for (int i = 0; i < 4; ++i) {
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(
            images[i].path,
            filename: id + i.toString(),
            contentType: MediaType("image", "jpeg"), //important
          ),
        });
        final response = await dio.post(
          url,
          data: formData,
          options: Options(
              headers: {
               },
              followRedirects: false,
              validateStatus: (status) {
                return status < 500;
              }),
        );
        if (response.data["meta"]["code"] != 200) throw response.data;
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<List<Challenge>> getChallengesForHome() async {
    try {
      List<Challenge> challenges = [];
      //fetch global challenges
      final response = await databaseReference
          .collection("global")
          .where("byUid", isNotEqualTo: userId)
          .get();

      Map<String, List<int>> hints = await loadHints();

      for (int i = 0; i < response.docs.length; ++i) {
        final element = response.docs[i];
        final responseForDone = await databaseReference
            .collection("Users")
            .doc(userId)
            .collection("globalDone")
            .where(FieldPath.documentId, isEqualTo: element.id)
            .get();

        bool isDone = false;
        if (responseForDone.docs.isNotEmpty) {
          if (responseForDone.docs[0].data()["done"] == true) isDone = true;
        }
        challenges.add(Challenge(
          cId: element.id,
          byId: element.data()["byUid"],
          byImageUrl: element.data()["byImageUrl"],
          byName: element.data()["byName"],
          dateTime: DateTime.parse(element.data()["dateTime"]),
          images: [null, null, null, null],
          done: isDone,
          word: element.data()["word"],
          isGlobal: true,
          countDone: element.data()["countDone"],
          hints: hints.containsKey(element.id) ? hints[element.id] : [],
        ));
      }

      //fetching private challenges
      final res = await databaseReference
          .collection("Users")
          .doc(userId)
          .collection("challenges")
          .where("byUid", isNotEqualTo: userId)
          .get();

      for (int i = 0; i < res.docs.length; ++i) {
        final element = res.docs[i];
        challenges.add(Challenge(
            cId: element.id,
            byId: element.data()["byUid"],
            byImageUrl: element.data()["byImageUrl"],
            byName: element.data()["byName"],
            dateTime: DateTime.parse(element.data()["dateTime"]),
            images: [null, null, null, null],
            done: element.data()["done"],
            hints: hints.containsKey(element.id) ? hints[element.id] : [],
            word: element.data()["word"]));
      }

      challenges.sort((a, b) {
        if (a.dateTime.isAfter(b.dateTime)) return 0;
        return 1;
      });

      return challenges;
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<void> correctGuess(Challenge challenge, Users currentUser) async {
    try {
      final DateTime dateTime = DateTime.now();
      //Point logic
      var points = 20;
      points += challenge.word.length * 2;
      points -= challenge.hints.length * 3;
      points += await streakForComplete();
      if (challenge.isGlobal) {
        await Future.wait([
          databaseReference.collection("Users").doc(userId).update({
            "challengeDone": FieldValue.increment(1),
          }),
          databaseReference
              .collection("global")
              .doc(challenge.cId)
              .update({"count": FieldValue.increment(1)}),
          databaseReference
              .collection("Users")
              .doc(userId)
              .collection("globalDone")
              .doc(challenge.cId)
              .set({"done": true}),
          databaseReference
              .collection("Users")
              .doc(userId)
              .update({"points": FieldValue.increment(points)}),
          databaseReference
              .collection("Users")
              .doc(userId)
              .collection("hints")
              .doc(challenge.cId)
              .delete()
        ]);
      } else {
        await Future.wait([
          databaseReference.collection("Users").doc(userId).update({
            "challengeDone": FieldValue.increment(1),
          }),
          databaseReference
              .collection("Users")
              .doc(userId)
              .collection("challenges")
              .doc(challenge.cId)
              .update({"done": true}),
          databaseReference
              .collection("Users")
              .doc(challenge.byId)
              .collection("byMe")
              .doc(challenge.cId)
              .set({
            "sharedDone": FieldValue.arrayUnion([
              {
                "uId": currentUser.uId,
                "name": currentUser.name,
                "imageUrl": currentUser.imageUrl,
              }
            ]),
          }, SetOptions(merge: true)),
          databaseReference
              .collection("Users")
              .doc(userId)
              .update({"points": FieldValue.increment(points)}),
          databaseReference
              .collection("Users")
              .doc(userId)
              .collection("hints")
              .doc(challenge.cId)
              .delete(),
          databaseReference
              .collection("notification")
              .doc(challenge.byId)
              .update({
            "data": FieldValue.arrayUnion([
              {
                "type": NotificationType.ChallengeDone.toString(),
                "dateTime": dateTime.toString(),
                "byId": userId,
                "seen": false,
                "imageUrl": currentUser.imageUrl,
                "byName": currentUser.name,
                "word": challenge.word,
                "hintCount": challenge.hints.length
              }
            ])
          }),
        ]);
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<List<List<Users>>> getChallengeDetails(Challenge challenge) async {
    try {
      final res = await databaseReference
          .collection("Users")
          .doc(challenge.byId)
          .collection("byMe")
          .doc(challenge.cId)
          .get();
      List<List<Users>> users = [];
      List<Users> doneUsers = [];
      if (res.data()["sharedDone"] != null)
        res.data()["sharedDone"].forEach((user) {
          doneUsers.add(Users(
              uId: user["uId"],
              name: user["name"],
              imageUrl: user["imageUrl"],
              email: null,
              points: null));
        });
      users.add(doneUsers);
      List<Users> todoUsers = [];

      if (res.data()["shared"] != null)
        res.data()["shared"].forEach((user) {
          todoUsers.add(Users(
              uId: user["uId"],
              name: user["name"],
              imageUrl: user["imageUrl"],
              email: null,
              points: null));
        });
      users.add(todoUsers);
      return users;
    } catch (e) {
      print(e);
      throw (e);
    }
  }
/*
  ************************************
  Challenge Section
  ************************************
  */

  Future<void> notificationSeen(List<dynamic> notification) async {
    notification.forEach((element) {
      element["seen"] = true;
    });
    await databaseReference
        .collection("notification")
        .doc(userId)
        .update({"data": notification});
  }
}
