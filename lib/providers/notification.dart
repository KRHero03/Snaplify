import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  final String userId;
  NotificationProvider(this.userId);
  final databaseReference = FirebaseFirestore.instance;
  Future<void> notificationSeen(List<dynamic> notification) async {
    for (int i = 0; i < notification.length; ++i) {
      await databaseReference
          .collection("Users")
          .doc(userId)
          .collection("notification")
          .doc(notification[i].id)
          .update({"seen": true});
    }
  }

  Future<List<dynamic>> getNotification(String last) async {
    try {
      final response = await databaseReference
          .collection("Users")
          .doc(userId)
          .collection("notification")
          .where("dateTime", isLessThan: last)
          .orderBy("dateTime", descending: true)
          .limit(10)
          .get();
      if (response.docs == null) return [];
      List<dynamic> notifications = [];
      notifications = response.docs;
      return notifications;
    } catch (e) {
      print(e);
      throw (e);
    }
  }
}
