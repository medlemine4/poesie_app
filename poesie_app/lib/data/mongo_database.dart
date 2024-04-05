// ignore_for_file: unnecessary_cast, constant_identifier_names

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
    return result.map((poet) => poet['nom'] as String).toList();
  }

  static Future<List<Map<String, dynamic>>> getDeewanNames() async {
  var db = await mongo.Db.create(MONGO_URL);
  await db.open();
  var collection = db.collection(COLLECTION_NAME2);
  var result = await collection.find().toList();
  await db.close();
  return result;
}


  static Future<Map<String, dynamic>> getPoetDetails(String poetName) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME);
    var query = mongo.where.eq('nom', poetName);
    var result = await collection.findOne(query);
    await db.close();
    return result ?? {};
  }

  static Future<List<Map<String, dynamic>>> getPoetDetailsList() async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME);
    var result = await collection.find().toList();
    await db.close();

    List<Map<String, dynamic>> poetsList = result.map((poet) {
      return {
        'ID_Auteur': poet['ID_Auteur'].toString(), // Include the ID
        'nom': poet['nom'],
        'prenom': poet['prenom'],
        'lieu_naissance': poet['lieu_naissance'],
        // 'image': poet['image'],
      };
    }).toList();

    return poetsList;
  }

  static Future<List<Map<String, dynamic>>> getDeewanByAuthorId(String authorId) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME2);
    var result = await collection.find(mongo.where.eq("ID_Auteur", int.parse(authorId))).toList();
    await db.close();
    return result.map((deewan) => deewan as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getPoemsByDeewanId(String deewanId) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME3);
    var result = await collection.find(mongo.where.eq("ID_Deewan", int.parse(deewanId))).toList();
    await db.close();
    return result.map((poem) => poem as Map<String, dynamic>).toList();
  }

  static Future<Map<String, dynamic>> getPoemDetails(String poemeName) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME3);
    var query = mongo.where.eq('Titre', poemeName);
    var result = await collection.findOne(query);
    await db.close();
    return result ?? {};
  }

  static Future<List<Map<String, dynamic>>> getAllPoems() async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME3);
    var result = await collection.find().toList();
    await db.close();
    return result.map((poem) => poem as Map<String, dynamic>).toList();
  }
}
