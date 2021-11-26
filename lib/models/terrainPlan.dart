import 'dart:core';
import 'package:backcountry_plan/models/helpers.dart';
import 'package:flutter/material.dart';

class TerrainPlanModel {
  TerrainMindset mindset;
  String areasToAvoid;
  String route;
  String mapLink;
  String turnaroundPoint;
  TimeOfDay turnaroundTime;

  TerrainPlanModel({
    required this.mindset,
    required this.areasToAvoid,
    required this.route,
    required this.mapLink,
    required this.turnaroundPoint,
    required this.turnaroundTime,
  });

  TerrainPlanModel.create()
      : this.mindset = TerrainMindset(),
        this.areasToAvoid = "",
        this.route = "",
        this.mapLink = "",
        this.turnaroundPoint = "",
        this.turnaroundTime = TimeOfDay.now();

  TerrainPlanModel.fromMap(Map<String, dynamic> map)
      : this.mindset = TerrainMindset.deserialize(map["mindset"]),
        this.areasToAvoid = map["areasToAvoid"] ?? "",
        this.route = map["route"] ?? "",
        this.mapLink = map["mapLink"] ?? "",
        this.turnaroundPoint = map["turnaroundPoint"] ?? "",
        this.turnaroundTime = deserializeTimeOfDay(map["turnaroundTime"]);

  Map<String, dynamic> toMap() {
    return {
      "mindset": this.mindset.serialize(),
      "areasToAvoid": this.areasToAvoid,
      "route": this.route,
      "mapLink": this.mapLink,
      "turnaroundPoint": this.turnaroundPoint,
      "turnaroundTime": serializeTimeOfDay(this.turnaroundTime),
    };
  }
}

enum MindsetType { keepItSimple, limitExposure, stepItOut }

extension MindsetTypeHelpers on MindsetType {
  String toName() => TerrainMindset.mindsetTypeNames[this]!;
}

class TerrainMindset {
  static final Map<MindsetType, String> mindsetTypeNames = {MindsetType.keepItSimple: "Keep it simple", MindsetType.limitExposure: "Limit Exposure", MindsetType.stepItOut: "Step it out"};
  MindsetType type;

  TerrainMindset() : type = MindsetType.keepItSimple;
  TerrainMindset.fromType(this.type);

  static TerrainMindset deserialize(String? s) {
    if (s == null || s.isEmpty) {
      return TerrainMindset();
    }

    return TerrainMindset.fromType(MindsetType.values[int.parse(s)]);
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
