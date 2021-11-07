import 'dart:io';

import 'package:backcountry_plan/checkinPoint.dart';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/common.dart';
import 'package:flutter/material.dart';

class TerrainPlanSummary extends StatelessWidget {
  final TerrainPlanModel plan;
  final Function(TerrainPlanModel) onTap;

  const TerrainPlanSummary({Key? key, required this.plan, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () => onTap(plan),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.mindset.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Turnaround time"), Text(plan.turnaroundTime.format(context))],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Route",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      plan.route,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Areas to avoid",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      plan.areasToAvoid,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TerrainPlanEditPage extends StatefulWidget {
  final TerrainPlanModel terrainPlan;

  TerrainPlanEditPage({Key? key, required this.terrainPlan}) : super(key: key);

  @override
  _TerrainPlanEditPageState createState() => _TerrainPlanEditPageState();
}

class _TerrainPlanEditPageState extends State<TerrainPlanEditPage> {
  final TextEditingController routeController = TextEditingController();
  final TextEditingController areasToAvoidController = TextEditingController();
  final TextEditingController turnaroundPointController = TextEditingController();
  List<CheckinPointModel> checkinPoints = [];

  @override
  void initState() {
    super.initState();
    routeController.text = widget.terrainPlan.route;
    areasToAvoidController.text = widget.terrainPlan.areasToAvoid;
    turnaroundPointController.text = widget.terrainPlan.turnaroundPoint;

    refreshCheckinPoints();
  }

  void refreshCheckinPoints() {
    CheckinPointModelProvider().getByTerrainPlanId(widget.terrainPlan.id!).then((_points) {
      stderr.writeln("new points");
      setState(() {
        checkinPoints = _points;
      });
    });
  }

  Future<void> _showTurnaroundTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.terrainPlan.turnaroundTime,
    );
    if (picked != null) {
      setState(() {
        widget.terrainPlan.turnaroundTime = picked;
      });
    }
  }

  _showEditCheckinPointPage(BuildContext context, CheckinPointModel? point) async {
    if (point == null) {
      point = CheckinPointModel.newForTerrainPlan(widget.terrainPlan.id!);
    }
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditCheckinPointPage(checkinPoint: point!);
    }));

    if (result != null) {
      stderr.writeln("non null");
      refreshCheckinPoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    var checkinPointList = checkinPoints.map((point) {
      return CheckinPointListItem(
        point: point,
        onTapped: _showEditCheckinPointPage,
      );
    }).toList();
    checkinPointList.sort((a, b) => a.point.time.compareTo(b.point.time));

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit terrain plan"),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context, widget.terrainPlan);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionText(text: "Terrain Mindset"),
                TerrainMindsetInput(mindset: widget.terrainPlan.mindset),
                const SizedBox(height: 20),
                SectionText(text: "Route"),
                const SizedBox(height: 10),
                TextField(
                  controller: routeController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 15,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What's your route?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.terrainPlan.route = routeController.text;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Column(
                  children: checkinPointList,
                ),
                ElevatedButton(
                  onPressed: () => _showEditCheckinPointPage(context, null),
                  child: Text('Add checkin point'),
                ),
                const SizedBox(height: 10),
                SectionText(text: "Areas to avoid"),
                const SizedBox(height: 10),
                TextField(
                  controller: areasToAvoidController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 8,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What are the slopes and areas to avoid?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.terrainPlan.areasToAvoid = areasToAvoidController.text;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SectionText(text: "Turnaround point and time"),
                const SizedBox(height: 10),
                TextField(
                  controller: turnaroundPointController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What's the turnaround point?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.terrainPlan.turnaroundPoint = turnaroundPointController.text;
                    });
                  },
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.terrainPlan.turnaroundTime.format(context),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showTurnaroundTimePicker(context),
                        child: Text('Change time'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckinPointListItem extends StatelessWidget {
  final CheckinPointModel point;
  final Function(BuildContext, CheckinPointModel) onTapped;

  const CheckinPointListItem({Key? key, required this.point, required this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(point.description),
        subtitle: Text(point.time.format(context)),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          onTapped(context, point);
        },
      ),
    );
  }
}

class TerrainMindsetInput extends StatefulWidget {
  final TerrainMindset mindset;
  const TerrainMindsetInput({Key? key, required this.mindset}) : super(key: key);

  @override
  _TerrainMindsetInputState createState() => _TerrainMindsetInputState();
}

class _TerrainMindsetInputState extends State<TerrainMindsetInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<MindsetType>(
        value: widget.mindset.type,
        hint: Text('Mindset'),
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        onChanged: (MindsetType? newValue) {
          if (newValue != null) {
            setState(() {
              widget.mindset.set(newValue);
            });
          }
        },
        items: MindsetType.values.map<DropdownMenuItem<MindsetType>>((MindsetType value) {
          return DropdownMenuItem<MindsetType>(
            value: value,
            child: Text(value.toName()),
          );
        }).toList(),
      ),
    );
  }
}
