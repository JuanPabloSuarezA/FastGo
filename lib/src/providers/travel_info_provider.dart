import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_go/src/models/travel_info.dart';

class TravelInfoProvider {
  CollectionReference _ref;

  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }

  Future<void> create(TravelInfo travelInfo) {
    String errorMessage;

    try {
      return _ref.doc(travelInfo.id).set(travelInfo.toJson());
    } catch (error) {
      errorMessage = error.code;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
  }
}
