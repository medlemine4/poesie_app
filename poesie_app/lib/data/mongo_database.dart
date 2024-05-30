// ignore_for_file: unnecessary_cast, constant_identifier_names

import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:mongo_dart/mongo_dart.dart';

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
    var deewans = await collection.find().toList();

    var poemsCollection = db.collection(COLLECTION_NAME3);

    // Pour chaque Diwan, obtenir le nombre de poèmes
    for (var deewan in deewans) {
      var poemCount = await poemsCollection
          .find(mongo.where.eq("ID_Deewan", deewan['Id_Deewan'].toString()))
          .length;
      deewan['poemCount'] = poemCount;
    }

    await db.close();
    return deewans;
  }

  static Future<Map<String, dynamic>> getPoetDetails(String poetName) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();

    var authorCollection = db.collection(COLLECTION_NAME);
    var deewanCollection = db.collection(COLLECTION_NAME2);
    var poemCollection = db.collection(COLLECTION_NAME3);

    var author =
        await authorCollection.findOne(mongo.where.eq('nom', poetName));

    if (author == null) {
      await db.close();
      return {};
    }

    var authorId = author['ID_Auteur'];

    var deewanCount = await deewanCollection
        .count(mongo.where.eq('ID_Auteur', int.parse(authorId)));
    var poemCount =
        await poemCollection.count(mongo.where.eq('ID_Auteur', authorId));

    await db.close();

    return {
      'nom': author['nom'],
      'description': author['description'],
      'deewanCount': deewanCount,
      'poemCount': poemCount
    };
  }

  static Future<List<Map<String, dynamic>>> getPoetDetailsList() async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();

    var authorCollection = db.collection(COLLECTION_NAME);
    var deewanCollection = db.collection(COLLECTION_NAME2);
    var poemCollection = db.collection(COLLECTION_NAME3);

    var authors = await authorCollection.find().toList();

    List<Map<String, dynamic>> poetsList = [];

    for (var author in authors) {
      var authorId = author['ID_Auteur'];

      var deewanCount = await deewanCollection
          .count(mongo.where.eq('ID_Auteur', int.parse(authorId)));
      var poemCount =
          await poemCollection.count(mongo.where.eq('ID_Auteur', authorId));

      poetsList.add({
        'ID_Auteur': authorId.toString(),
        'nom': author['nom'],
        'prenom': author['prenom'],
        'deewanCount': deewanCount,
        'poemCount': poemCount,
        'date_naissance': int.parse(author['date_naissance']
            .toString()) // Ensure date_naissance is an integer
      });
    }
    return poetsList;
  }

  static Future<Map<String, dynamic>> getPoemById(String id) async {
    var db = await mongo.Db.create(MONGO_URL);
    var collection = db.collection(COLLECTION_NAME3);
    var poem = await collection.findOne(where.eq('ID_Poeme', id));
    return poem ?? {};
  }

  static Future<List<Map<String, dynamic>>> getDeewanByAuthorId(
      String authorId) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME2);
    var deewans = await collection
        .find(mongo.where.eq('ID_Auteur', int.parse(authorId)))
        .toList();

    var poemsCollection = db.collection(COLLECTION_NAME3);

    // Pour chaque Diwan, obtenir le nombre de poèmes
    for (var deewan in deewans) {
      var poemCount = await poemsCollection
          .find(mongo.where.eq("ID_Deewan", deewan['Id_Deewan'].toString()))
          .length;
      deewan['poemCount'] = poemCount;
    }

    await db.close();
    return deewans;
  }

  static Future<List<Map<String, dynamic>>> getPoemsByDeewanId(
      String deewanId) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME3);
    var result =
        await collection.find(mongo.where.eq("ID_Deewan", deewanId)).toList();
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

  static Future<List<Map<String, dynamic>>> searchAllCollections(
      String searchText) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();

    var poetCollection = db.collection(COLLECTION_NAME);
    var deewanCollection = db.collection(COLLECTION_NAME2);
    var poemCollection = db.collection(COLLECTION_NAME3);

    var poetQuery = {
      '\$or': [
        {
          'nom': {'\$regex': searchText, '\$options': 'i'}
        },
        {
          'prenom': {'\$regex': searchText, '\$options': 'i'}
        }
      ]
    };

    var poetResults = await poetCollection.find(poetQuery).toList();

    for (var poet in poetResults) {
      var deewanCount = await deewanCollection
          .find(mongo.where.eq("ID_Auteur", int.parse(poet['ID_Auteur'])))
          .length;

      var deewanList = await deewanCollection
          .find(mongo.where.eq("ID_Auteur", int.parse(poet['ID_Auteur'])))
          .toList();

      var poemCount = 0;
      for (var deewan in deewanList) {
        var count = await poemCollection
            .find(mongo.where.eq("ID_Deewan", deewan['Id_Deewan'].toString()))
            .length;
        poemCount += count;
      }

      poet['deewanCount'] = deewanCount;
      poet['poemCount'] = poemCount;
    }

    var deewanQuery = {
      'nom': {'\$regex': searchText, '\$options': 'i'}
    };

    var deewanResults = await deewanCollection.find(deewanQuery).toList();

    for (var deewan in deewanResults) {
      var poemCount = await poemCollection
          .find(mongo.where.eq("ID_Deewan", deewan['Id_Deewan'].toString()))
          .length;
      deewan['poemCount'] = poemCount;
    }

    var poemQuery = {
      '\$or': [
        {
          'Titre': {'\$regex': searchText, '\$options': 'i'}
        },
        {
          'Contenu': {'\$regex': searchText, '\$options': 'i'}
        }
      ]
    };

    var poemResults = await poemCollection.find(poemQuery).toList();

    await db.close();

    return [...poetResults, ...deewanResults, ...poemResults];
  }
}
