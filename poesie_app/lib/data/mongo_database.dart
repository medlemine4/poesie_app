// File: lib/data/mongo_database.dart

// ignore_for_file: constant_identifier_names

import 'package:mongo_dart/mongo_dart.dart' as mongo;

const MONGO_URL =
    "mongodb+srv://medleminehaj:22482188@maincluster.g7p5xjc.mongodb.net/poesie_DB?retryWrites=true&w=majority&appName=mainCluster";
const COLLECTION_NAME = "Auteur";
const COLLECTION_NAME2 = "Deewan";
const COLLECTION_NAME3 = "Poeme";

class MongoDataBase {
  static Future<List<String>> getPoetNames() async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME);
    var result = await collection.find().toList();
    await db.close();
    // Récupérer seulement les noms des auteurs
    return result.map((poet) => poet['nom'] as String).toList();
  }

  static Future<List<String>> getDeewanNames([int? authorId]) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME2);
    var query = authorId != null ? mongo.where.eq('ID_Auteur', authorId) : {};
    var result = await collection.find(query).toList();
    await db.close();
    // Récupérer seulement les noms des Deewan de l'auteur spécifié
    return result.map((deewan) => deewan['nom'] as String).toList();
  }

 static Future<Map<String, dynamic>> getPoetDetails(String poetName) async {
  var db = await mongo.Db.create(MONGO_URL);
  await db.open();
  var collection = db.collection(COLLECTION_NAME);
  var query = mongo.where.eq('nom', poetName);
  var result = await collection.findOne(query);
  await db.close();
  return result ?? {}; // Return an empty map if result is null
}

static Future<List<Map<String, dynamic>>> getPoetDetailsList() async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME);
    var result = await collection.find().toList();
    await db.close();

    // Map each document to a Map<String, dynamic> containing poet details
    List<Map<String, dynamic>> poetsList = result.map((poet) {
      return {
        'nom': poet['nom'],
        'prenom': poet['prenom'],
        'lieu_naissance': poet['lieu_naissance'],
        'image': poet['image'],
      };
    }).toList();

    return poetsList;
  }

  }

