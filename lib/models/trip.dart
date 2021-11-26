import 'dart:core';
import 'package:backcountry_plan/db.dart';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/models/helpers.dart';
import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';

class TripModel {
  int? key;
  String name;
  DateTime date;
  String keyMessage;
  String forecast;
  TerrainPlanModel terrainPlan;
  List<AvalancheProblemModel> problems;
  List<CheckinPointModel> checkinPoints;

  String friendlyDate() {
    return DateFormat.yMMMd().format(date);
  }

  TripModel({
    required this.name,
    required this.date,
    required this.keyMessage,
    required this.forecast,
    required this.terrainPlan,
    required this.problems,
    required this.checkinPoints,
  });

  TripModel.create()
      : this.name = "",
        this.date = DateTime.now(),
        this.keyMessage = "",
        this.forecast = "",
        this.terrainPlan = TerrainPlanModel.create(),
        this.problems = [],
        this.checkinPoints = [];

  TripModel.fromMap(int key, Map<String, dynamic> map)
      : this.key = key,
        this.name = map["name"],
        this.date = deserializeDateTime(map["date"]),
        this.keyMessage = map["keyMessage"],
        this.forecast = map["forecast"],
        this.terrainPlan = TerrainPlanModel.fromMap(map["terrainPlan"]),
        this.problems = (map["problems"] as List).map((p) => AvalancheProblemModel.fromMap(p)).toList(),
        this.checkinPoints = (map["checkinPoints"] as List).map((p) => CheckinPointModel.fromMap(p)).toList();

  Map<String, dynamic> toMap() {
    return {
      "name": this.name,
      "date": serializeDateTime(this.date), // serialize?
      "keyMessage": this.keyMessage,
      "forecast": this.forecast,
      "terrainPlan": this.terrainPlan.toMap(),
      "problems": this.problems.map((p) => p.toMap()).toList(),
      "checkinPoints": this.checkinPoints.map((p) => p.toMap()).toList(),
    };
  }

  bool isPersisted() {
    return key != null;
  }
}

class TripStore {
  static final String key = "trip";
  static late StoreRef<int, Map<String, Object?>> store;

  static final TripStore _singleton = TripStore._internal();

  factory TripStore() {
    return _singleton;
  }

  TripStore._internal() {
    store = intMapStoreFactory.store(TripStore.key);
  }

  Future<List<TripModel>> all() async {
    var db = await JsonDatabaseManager.instance.database;

    var results = await store.find(db);

    return results.map((r) => TripModel.fromMap(r.key, r.value)).toList();
  }

  Future<TripModel> save(TripModel trip) async {
    var db = await JsonDatabaseManager.instance.database;

    if (trip.key != null) {
      var record = store.record(trip.key!);
      await record.put(db, trip.toMap());
    } else {
      var map = trip.toMap();
      var key = await store.add(db, map);
      trip.key = key;
    }

    return trip;
  }

  Future delete(TripModel trip) async {
    var db = await JsonDatabaseManager.instance.database;
    if (trip.key != null) {
      var record = store.record(trip.key!);
      await record.delete(db);
    }
  }
}
