import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:backcountry_plan/db.dart';
import 'package:backcountry_plan/models/base.dart';
import 'package:backcountry_plan/models/plan.dart';

class CheckinPointModel extends BaseModel {
  String description;
  TimeOfDay time;
  int terrainPlanId;

  CheckinPointModel({
    id,
    required this.description,
    required this.time,
    required this.terrainPlanId,
  }) : super(id: id);

  CheckinPointModel.newForTerrainPlan(int terrainPlanId)
      : this.description = "",
        this.time = TimeOfDay.now(),
        this.terrainPlanId = terrainPlanId;
}

class CheckinPointModelProvider extends BaseProvider<CheckinPointModel> {
  static final String checkinPointTableName = "checkin_point";
  static final String checkinPointColumnId = "id";
  static final String _columnDescription = "_columnDescription";
  static final String _columnTime = "time";
  static final String _columnTerrainPlanId = 'terrain_plan_id';

  static final List<String> _columns = [checkinPointColumnId, _columnDescription, _columnTime, _columnTerrainPlanId];

  static final String createStatement = '''
                                        CREATE TABLE $checkinPointTableName (
                                          $checkinPointColumnId INTEGER PRIMARY KEY,
                                          $_columnDescription TEXT,
                                          $_columnTime TEXT,
                                          $_columnTerrainPlanId INTEGER,
                                          FOREIGN KEY ($_columnTerrainPlanId) REFERENCES ${PlanModelProvider.planTableName}(${PlanModelProvider.planColumnId})
                                        )
                                        ''';

  static final CheckinPointModelProvider _singleton = CheckinPointModelProvider._internal();

  factory CheckinPointModelProvider() {
    return _singleton;
  }

  CheckinPointModelProvider._internal() {
    tableName = checkinPointTableName;
    columnId = checkinPointColumnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(CheckinPointModel checkinPoint) {
    var map = <String, dynamic>{
      _columnTerrainPlanId: checkinPoint.terrainPlanId,
      _columnDescription: checkinPoint.description,
      _columnTime: serializeTimeOfDay(checkinPoint.time),
    };

    if (checkinPoint.id != null) {
      map[columnId] = checkinPoint.id;
    }

    return map;
  }

  CheckinPointModel fromMap(Map e) {
    return CheckinPointModel(
      id: e[columnId],
      description: e[_columnDescription],
      time: deserializeTimeOfDay(e[_columnTime]),
      terrainPlanId: e[_columnTerrainPlanId],
    );
  }

  Future<List<CheckinPointModel>> getByTerrainPlanId(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$_columnTerrainPlanId = ?',
      whereArgs: [id],
    );
    return maps.map((e) => fromMap(e)).toList();
  }
}
