import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poster_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final CollectionReference _postersCollection = FirebaseFirestore.instance
      .collection('posters');

  // Insert a poster
  Future<String> insertPoster(PosterModel poster) async {
    final docRef = await _postersCollection.add(poster.toMap());
    return docRef.id;
  }

  // Update a poster
  Future<void> updatePoster(String docId, PosterModel poster) async {
    await _postersCollection.doc(docId).update(poster.toMap());
  }

  // Delete a poster
  Future<void> deletePoster(String docId) async {
    await _postersCollection.doc(docId).delete();
  }

  // Get all posters
  Future<List<PosterModelFirestore>> getAllPosters() async {
    final snapshot = await _postersCollection
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PosterModelFirestore.fromFirestore(doc))
        .toList();
  }

  // Search posters by title
  Future<List<PosterModelFirestore>> searchPosters(String query) async {
    final snapshot = await _postersCollection
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snapshot.docs
        .map((doc) => PosterModelFirestore.fromFirestore(doc))
        .toList();
  }

  // Get poster by id
  Future<PosterModelFirestore?> getPosterById(String docId) async {
    final doc = await _postersCollection.doc(docId).get();
    if (doc.exists) {
      return PosterModelFirestore.fromFirestore(doc);
    }
    return null;
  }
}

// Extended model for Firestore with document ID
class PosterModelFirestore extends PosterModel {
  final String docId;

  PosterModelFirestore({
    required this.docId,
    super.id,
    required super.title,
    required super.price,
    required super.unit,
    super.offerPrice,
    required super.description,
    super.imageBase64,
    super.createdAt,
    super.updatedAt,
  });

  factory PosterModelFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PosterModelFirestore(
      docId: doc.id,
      id: data['id'] as int?,
      title: data['title'] as String,
      price: data['price'] as String,
      unit: data['unit'] as String,
      offerPrice: data['offerPrice'] as String? ?? '',
      description: data['description'] as String,
      imageBase64: data['imageBase64'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
