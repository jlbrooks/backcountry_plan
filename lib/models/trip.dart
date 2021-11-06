import 'dart:core';
import 'package:backcountry_plan/models/base.dart';
import 'package:backcountry_plan/models/plan.dart';
import 'package:intl/intl.dart';

class TripModel extends BaseModel {
  String name;
  DateTime date;
  int? planId;
  PlanModel? plan;

  String friendlyDate() {
    return DateFormat.yMMMd().format(date);
  }

  TripModel({
    id,
    required this.name,
    required this.date,
    this.planId,
    this.plan,
  }) : super(id: id);

  TripModel.create()
      : this.name = "",
        this.date = DateTime.now();
}

class TripModelProvider extends BaseProvider<TripModel> {
  static final String tripTableName = "backcountry_trip";
  static final String tripColumnId = "id";
  static final String _columnName = "name";
  static final String _columnDate = "date";
  static final List<String> _columns = [tripColumnId, _columnName, _columnDate];

  static final String createStatement = '''
                                        CREATE TABLE $tripTableName (
                                          $tripColumnId INTEGER PRIMARY KEY,
                                          $_columnName TEXT,
                                          $_columnDate TEXT
                                        )
                                        ''';

  static final TripModelProvider _singleton = TripModelProvider._internal();

  factory TripModelProvider() {
    return _singleton;
  }

  TripModelProvider._internal() {
    tableName = tripTableName;
    columnId = tripColumnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(TripModel trip) {
    var map = <String, dynamic>{
      _columnName: trip.name,
      _columnDate: serializeDateTime(trip.date),
    };

    if (trip.id != null) {
      map[columnId] = trip.id;
    }

    return map;
  }

  TripModel fromMap(Map e) {
    return TripModel(
      id: e[columnId],
      name: e[_columnName],
      date: deserializeDateTime(e[_columnDate]),
    );
  }
}
