import 'dart:ffi';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoFireProvider {
  CollectionReference _ref;
  Geoflutterfire _geo;

  GeoFireProvider() {
    _ref = FirebaseFirestore.instance.collection('locations');
    _geo = Geoflutterfire();
  }

  Stream<List<DocumentSnapshot>> conductoresCercanos(
      double lat, double lng, double radius) {
    GeoFirePoint center = _geo.point(latitude: lat, longitude: lng);

    return _geo
        .collection(
            collectionRef: _ref.where('status', isEqualTo: 'drivers_available'))
        .within(center: center, radius: radius, field: 'position');
  }

  Stream<DocumentSnapshot> getlocationID(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Void> create(String id, double lat, double lng) {
    GeoFirePoint mylocation = _geo.point(latitude: lat, longitude: lng);
    return _ref
        .doc(id)
        .set({'status': 'drivers_available', 'position': mylocation.data});
  }

  Future<Void> delete(String id) {
    return _ref.doc(id).delete();
  }
}
