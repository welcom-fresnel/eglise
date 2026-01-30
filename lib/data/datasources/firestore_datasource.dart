import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';

/// Data source Firestore
/// 
/// Gère toutes les opérations de lecture/écriture dans Firestore.
/// Cette couche est responsable de la communication directe avec Firestore.
class FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSource(this._firestore);

  /// Récupère un document d'une collection
  Future<Result<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      AppLogger.d('Récupération document: $collection/$documentId');
      
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        return Error(CacheFailure('Document non trouvé: $documentId'));
      }

      final data = doc.data();
      if (data == null) {
        return Error(CacheFailure('Document vide: $documentId'));
      }

      return Success(data);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la récupération du document', e, stackTrace);
      return Error(ServerFailure('Erreur Firestore: ${e.toString()}'));
    }
  }

  /// Récupère plusieurs documents d'une collection avec pagination
  Future<Result<List<Map<String, dynamic>>>> getDocuments({
    required String collection,
    String? lastDocumentId,
    int limit = 20,
    String? orderBy,
    bool descending = true,
    Map<String, dynamic>? whereConditions,
  }) async {
    try {
      AppLogger.d('Récupération documents: $collection (limit: $limit)');
      
      Query query = _firestore.collection(collection);

      // Filtres WHERE
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Tri
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Pagination
      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection(collection)
            .doc(lastDocumentId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      // Limite
      query = query.limit(limit);

      final snapshot = await query.get();
      final documents = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();

      AppLogger.d('${documents.length} documents récupérés');
      return Success(documents);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la récupération des documents', e, stackTrace);
      return Error(ServerFailure('Erreur Firestore: ${e.toString()}'));
    }
  }

  /// Crée un document
  Future<Result<String>> createDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      AppLogger.d('Création document: $collection/$documentId');
      
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data);

      AppLogger.d('Document créé avec succès');
      return Success(documentId);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la création du document', e, stackTrace);
      return Error(ServerFailure('Erreur Firestore: ${e.toString()}'));
    }
  }

  /// Met à jour un document
  Future<Result<void>> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      AppLogger.d('Mise à jour document: $collection/$documentId');
      
      await _firestore
          .collection(collection)
          .doc(documentId)
          .update(data);

      AppLogger.d('Document mis à jour avec succès');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la mise à jour du document', e, stackTrace);
      return Error(ServerFailure('Erreur Firestore: ${e.toString()}'));
    }
  }

  /// Supprime un document
  Future<Result<void>> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      AppLogger.d('Suppression document: $collection/$documentId');
      
      await _firestore
          .collection(collection)
          .doc(documentId)
          .delete();

      AppLogger.d('Document supprimé avec succès');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la suppression du document', e, stackTrace);
      return Error(ServerFailure('Erreur Firestore: ${e.toString()}'));
    }
  }

  /// Stream d'un document (écoute en temps réel)
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return {
        'id': snapshot.id,
        ...snapshot.data() as Map<String, dynamic>,
      };
    });
  }

  /// Stream d'une collection (écoute en temps réel)
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    String? orderBy,
    bool descending = true,
    Map<String, dynamic>? whereConditions,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (whereConditions != null) {
      whereConditions.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    });
  }

  /// Transaction: incrémente un champ numérique
  Future<Result<void>> incrementField({
    required String collection,
    required String documentId,
    required String field,
    required int value,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final ref = _firestore.collection(collection).doc(documentId);
        final snapshot = await transaction.get(ref);
        
        if (!snapshot.exists) {
          throw Exception('Document non trouvé');
        }

        final currentValue = (snapshot.data()?[field] as int?) ?? 0;
        transaction.update(ref, {field: currentValue + value});
      });

      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de l\'incrément', e, stackTrace);
      return Error(ServerFailure('Erreur Firestore: ${e.toString()}'));
    }
  }
}

