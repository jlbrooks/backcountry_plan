import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:backcountry_plan/db.dart';
import 'package:backcountry_plan/models/base.dart';
import 'package:backcountry_plan/models/trip.dart';

class PlanModel extends BaseModel {
  String keyMessage;
  String forecast;
  int tripId;

  PlanModel({id, this.keyMessage, this.forecast, this.tripId}) : super(id: id);
}

class PlanModelProvider extends BaseProvider<PlanModel> {
  static final String planTableName = "backcountry_plan";
  static final String planColumnId = "id";
  static final String _columnKeyMessage = "key_message";
  static final String _columnForecast = "forecast";
  static final String _columnTripId = "trip_id";
  static final List<String> _columns = [
    planColumnId,
    _columnKeyMessage,
    _columnForecast,
    _columnTripId
  ];

  static final String createStatement = '''
                                        CREATE TABLE $planTableName (
                                          $planColumnId INTEGER PRIMARY KEY,
                                          $_columnKeyMessage TEXT,
                                          $_columnForecast TEXT,
                                          $_columnTripId INTEGER,
                                          FOREIGN KEY ($_columnTripId) REFERENCES ${TripModelProvider.tripTableName}(${TripModelProvider.tripColumnId})
                                        )
                                        ''';

  static final PlanModelProvider _singleton = PlanModelProvider._internal();

  factory PlanModelProvider() {
    return _singleton;
  }

  PlanModelProvider._internal() {
    tableName = planTableName;
    columnId = planColumnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(PlanModel plan) {
    var map = <String, dynamic>{
      _columnTripId: plan.tripId,
      _columnKeyMessage: plan.keyMessage,
      _columnForecast: plan.forecast,
    };

    if (plan.id != null) {
      map[columnId] = plan.id;
    }

    return map;
  }

  PlanModel fromMap(Map e) {
    return PlanModel(
      id: e[columnId],
      keyMessage: e[_columnKeyMessage],
      forecast: e[_columnForecast],
      tripId: e[_columnTripId],
    );
  }

  Future<PlanModel> getByTripId(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$_columnTripId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return fromMap(maps.first);
    }
    return null;
  }
}
