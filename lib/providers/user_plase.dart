import 'dart:io';

import 'package:favorite_places/model/places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatebase() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(path.join(dbpath, 'place.db'),
      onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE user_place(id TEXT PRIMARY KEY,title TEXT,image TEXT,lat REAL,lng REAL,address TEXT)');
  }, version: 1);
  return db;
}

class UserPlaseNotifier extends StateNotifier<List<Place>> {
  UserPlaseNotifier() : super(const []);

  Future<void> loadPlace() async {
    final db = await _getDatebase();
    final data = await db.query('user_place');
    final plases = data
        .map(
          (e) => Place(
            id: e['id'] as String,
            title: e['title'] as String,
            image: File(e['image'] as String),
            location: PlaceLocation(
                latitude: e['lat'] as double,
                longitude: e['lng'] as double,
                address: e['address'] as String),
          ),
        )
        .toList();
    state = plases;
  }

  void addPlase(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    final newPlace = Place(
      title: title,
      image: copiedImage,
      location: location,
    );
    final db = await _getDatebase();
    db.insert('user_place', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }
}

final UserPlaseProvider = StateNotifierProvider<UserPlaseNotifier, List<Place>>(
    (ref) => UserPlaseNotifier());
