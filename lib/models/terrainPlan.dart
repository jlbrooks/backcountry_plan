import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:backcountry_plan/db.dart';
import 'package:backcountry_plan/models/base.dart';
import 'package:backcountry_plan/models/plan.dart';

class TerrainPlanModel extends BaseModel {
  TerrainMindset mindset;
  String areasToAvoid;
  String route;
  String turnaroundPoint;
  TimeOfDay turnaroundTime;
  int planId;

  TerrainPlanModel(
      {id,
      this.mindset,
      this.areasToAvoid,
      this.route,
      this.turnaroundPoint,
      this.turnaroundTime,
      this.planId})
      : super(id: id);

  TerrainPlanModel.newForPlan(int planId)
      : this.mindset = TerrainMindset(),
        this.areasToAvoid = "",
        this.route = "",
        this.turnaroundPoint = "",
        this.turnaroundTime = TimeOfDay.now(),
        this.planId = planId;
}

class TerrainPlanModelProvider extends BaseProvider<TerrainPlanModel> {
  static final String terrainPlanTableName = "terrain_plan";
  static final String terrainPlanColumnId = "id";
  static final String _columnMindset = "mindset";
  static final String _columnAreasToAvoid = "areas_to_avoid";
  static final String _columnRoute = "route";
  static final String _columnTurnaroundPoint = "turnaround_point";
  static final String _columnTurnaroundTime = "turnaround_time";
  static final String _columnPlanId = 'plan_id';

  static final List<String> _columns = [
    terrainPlanColumnId,
    _columnMindset,
    _columnAreasToAvoid,
    _columnRoute,
    _columnTurnaroundPoint,
    _columnTurnaroundTime,
    _columnPlanId
  ];

  static final String createStatement = '''
                                        CREATE TABLE $terrainPlanTableName (
                                          $terrainPlanColumnId INTEGER PRIMARY KEY,
                                          $_columnMindset TEXT,
                                          $_columnAreasToAvoid TEXT,
                                          $_columnRoute TEXT,
                                          $_columnTurnaroundPoint TEXT,
                                          $_columnTurnaroundTime TEXT,
                                          $_columnPlanId INTEGER,
                                          FOREIGN KEY ($_columnPlanId) REFERENCES ${PlanModelProvider.planTableName}(${PlanModelProvider.planColumnId})
                                        )
                                        ''';

  static final TerrainPlanModelProvider _singleton =
      TerrainPlanModelProvider._internal();

  factory TerrainPlanModelProvider() {
    return _singleton;
  }

  TerrainPlanModelProvider._internal() {
    tableName = terrainPlanTableName;
    columnId = terrainPlanColumnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(TerrainPlanModel terrainPlan) {
    var map = <String, dynamic>{
      _columnPlanId: terrainPlan.planId,
      _columnMindset: terrainPlan.mindset.serialize(),
      _columnAreasToAvoid: terrainPlan.areasToAvoid,
      _columnRoute: terrainPlan.route,
      _columnTurnaroundPoint: terrainPlan.turnaroundPoint,
      _columnTurnaroundTime: serializeTimeOfDay(terrainPlan.turnaroundTime),
    };

    if (terrainPlan.id != null) {
      map[columnId] = terrainPlan.id;
    }

    return map;
  }

  TerrainPlanModel fromMap(Map e) {
    return TerrainPlanModel(
      id: e[columnId],
      mindset: TerrainMindset.deserialize(e[_columnMindset]),
      areasToAvoid: e[_columnAreasToAvoid],
      route: e[_columnRoute],
      turnaroundPoint: e[_columnTurnaroundPoint],
      turnaroundTime: deserializeTimeOfDay(e[_columnTurnaroundTime]),
      planId: e[_columnPlanId],
    );
  }

  Future<List<TerrainPlanModel>> getByPlanId(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$_columnPlanId = ?',
      whereArgs: [id],
    );
    return maps.map((e) => fromMap(e)).toList();
  }
}

enum MindsetType { keepItSimple, limitExposure, stepItOut }

extension MindsetTypeHelpers on MindsetType {
  String toName() => TerrainMindset.mindsetTypeNames[this];
}

class TerrainMindset {
  static final Map<MindsetType, String> mindsetTypeNames = {
    MindsetType.keepItSimple: "Keep it simple",
    MindsetType.limitExposure: "Limit Exposure",
    MindsetType.stepItOut: "Step it out"
  };
  MindsetType type;

  TerrainMindset() : type = MindsetType.keepItSimple;
  TerrainMindset.fromType(this.type);

  static TerrainMindset deserialize(String s) {
    if (s.isNotEmpty) {
      return TerrainMindset.fromType(MindsetType.values[int.parse(s)]);
    }

    return TerrainMindset();
  }

  String serialize() {
    return type.index.toString();
  }

  void set(MindsetType value) {
    type = value;
  }

  @override
  String toString() {
    return type.toName();
  }
}
