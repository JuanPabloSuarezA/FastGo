import 'package:fast_go/src/models/client.dart';

import "package:cloud_firestore/cloud_firestore.dart";

class ClientProvider {
  CollectionReference _ref;

  ClientProvider() {
    _ref = FirebaseFirestore.instance.collection("Clients");
  }

  Future<void> create(Client client) {
    String errorMessage;

    try {
      return _ref.doc(client.id).set(client.toJson());
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

  Future<Client> getClientWithId(String id) async {
    DocumentSnapshot doc = await _ref.doc(id).get();
    Client client;
    if (doc.exists) {
      client = Client.fromJson(doc.data());

      return client;
    }
    return null;
  }
}
