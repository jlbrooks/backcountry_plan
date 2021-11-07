import 'dart:core';
import 'package:backcountry_plan/db.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseModel {
  int? id;

  bool isPersisted() {
    return (this.id != null);
  }

  BaseModel({this.id});
}

abstract class BaseProvider<T extends BaseModel> {
  late String tableName;
  late String columnId;
  late List<String> columns;

  Future save(T model) async {
    if (model.id == null) {
      model.id = await _insert(model);
    } else {
      _update(model);
    }
  }

  Future<void> delete(T model) async {
    var db = await DatabaseManager.instance.database;
    await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> _insert(T model) async {
    var db = await DatabaseManager.instance.database;
    int id = await db.insert(tableName, toMap(model));
    return id;
  }

  Future<int> _update(T model) async {
    var db = await DatabaseManager.instance.database;
    int id = await db.update(
      tableName,
      toMap(model),
      where: '$columnId = ?',
      whereArgs: [model.id],
    );

    return id;
  }

  Future<T?> get(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return fromMap(maps.first);
    }
    return null;
  }

  Future<List<T>> all() async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
    );

    return maps.map((e) => fromMap(e)).toList();
  }

  String serializeDateTime(DateTime dt) {
    return dt.toUtc().toIso8601String();
  }

  DateTime deserializeDateTime(String s) {
    return DateTime.tryParse(s)!.toLocal();
  }

  String serializeTimeOfDay(TimeOfDay td) {
    return "${td.hour}:${td.minute}";
  }

  TimeOfDay deserializeTimeOfDay(String s) {
    var split = s.split(":");
    return TimeOfDay(hour: int.parse(split[0]), minute: int.parse(split[1]));
  }

  Map<String, dynamic> toMap(T trip);

  T fromMap(Map e);
}
