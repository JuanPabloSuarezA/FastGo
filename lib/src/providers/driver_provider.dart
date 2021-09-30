import 'package:fast_go/src/models/driver.dart';

import "package:cloud_firestore/cloud_firestore.dart";

class DriverProvider {
  CollectionReference _ref;

  DriverProvider() {
    _ref = FirebaseFirestore.instance.collection("Drivers");
  }

  Future<void> create(Driver driver) {
    String errorMessage;

    try {
      return _ref.doc(driver.id).set(driver.toJson());
    } catch (e) {
      errorMessage = e.code;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
  }

  Stream<DocumentSnapshot> GetIDStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Driver> getDriverWithId(String id) async {
    DocumentSnapshot doc = await _ref.doc(id).get();

    Driver driver;

    if (doc.exists) {
      driver = Driver.fromJson(doc.data());

      return driver;
    }

    return null;
  }
}
