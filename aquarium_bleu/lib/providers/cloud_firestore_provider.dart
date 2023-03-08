import 'package:aquarium_bleu/models/parameter.dart';
import 'package:aquarium_bleu/models/tank.dart';
import 'package:aquarium_bleu/models/task/interval_task.dart';
import 'package:aquarium_bleu/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CloudFirestoreProvider extends ChangeNotifier {
  late String _uid;

  set uid(String uid) {
    _uid = uid;
  }

  void writeNewUser(String? uid, String? email) async {
    _uid = uid!;
    final docUser = FirebaseFirestore.instance.collection('users').doc(uid);

    final json = {'email': email};

    await docUser.set(json);
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('users');

      var doc = await collectionRef.doc(docId).get();

      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Tank>> readTanks() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .snapshots()
        .map((event) => event.docs
            .map((doc) => Tank.fromJson(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Parameter>> readParameters(String tankId, String parameter) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(tankId)
        .collection(parameter)
        .orderBy("date")
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => Parameter.fromJson(doc.data())).toList());
  }

  Future addParameter(String tankId, String paramName, Parameter param) async {
    final docParam = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(tankId)
        .collection(paramName)
        .doc(const Uuid().v4());

    final json = param.toJson();

    await docParam.set(json);
  }

  Stream<List<IntervalTask>> readIntervalTasks(String docId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(docId)
        .collection('intervalTasks')
        .orderBy("dueDate")
        .snapshots()
        .map((event) => event.docs
            .map((doc) => IntervalTask.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future updateIntervalTask(IntervalTask updatedTask, String tankId) async {
    final intervalTask = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(tankId)
        .collection('intervalTasks')
        .doc(updatedTask.docId);

    intervalTask.update(updatedTask.toJson());
  }

  Future<String> addTank(String name, bool isFreshWater) async {
    final String docId = const Uuid().v4();
    final docTank = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(docId);

    // TODO: redo
    final json = {
      'name': name,
      'isFreshwater': isFreshWater,
    };

    await docTank.set(json);

    return docId;
  }

  Future addDefParamVisPrefs(String tankId) async {
    final visibilityDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(tankId)
        .collection('prefs')
        .doc('isParamVisible');

    final json = {
      for (String param in Strings.params) param: true,
    };

    await visibilityDoc.set(json);
  }

  Future<Map<String, bool>?> readParamVisPrefs(String tankId) async {
    var doc = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tanks')
        .doc(tankId)
        .collection('prefs')
        .doc('isParamVisible');

    await doc.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        return data;
      }
    });

    return null;
  }
}
