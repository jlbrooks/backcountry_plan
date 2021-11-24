import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/plan.dart';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TripSummaryPage extends StatefulWidget {
  final TripModel trip;
  TripSummaryPage({Key? key, required this.trip}) : super(key: key);

  @override
  _TripSummaryPageState createState() => _TripSummaryPageState();
}

class _TripSummaryPageState extends State<TripSummaryPage> {
  late PlanModel plan = PlanModel.newForTrip(widget.trip.id!);
  late TerrainPlanModel terrainPlan = TerrainPlanModel.newForPlan(-1);
  List<AvalancheProblemModel> problems = [];
  List<CheckinPointModel> checkinPoints = [];

  @override
  void initState() {
    super.initState();

    PlanModelProvider().getOrNewByTripId(widget.trip.id!).then((_plan) async {
      var _problems = await AvalancheProblemModelProvider().getByPlanId(_plan.id!);
      var _terrainPlan = await TerrainPlanModelProvider().getOrNewByPlanId(_plan.id!);
      var _checkinPoints = await CheckinPointModelProvider().getByTerrainPlanId(_terrainPlan.id!);
      setState(() {
        plan = _plan;
        problems = _problems;
        terrainPlan = _terrainPlan;
        checkinPoints = _checkinPoints;
      });
    });
  }

  _onEdit(BuildContext context) {}

  _onEditProblem(BuildContext context, AvalancheProblemModel problem) {}

  @override
  Widget build(BuildContext context) {
    var problemList = ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: problems.length,
      itemBuilder: (context, index) => ProblemSummary(problem: problems[index], onEditProblem: _onEditProblem),
    );

    List<Widget> checkinPointList = checkinPoints
        .map((p) => Text(
              "${p.time.format(context)} - ${p.description}",
              style: TextStyle(fontSize: 16),
            ))
        .toList();

    return ListScreen(
      titleText: widget.trip.name,
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _onEdit(context),
        )
      ],
      children: [
        Text(
          widget.trip.friendlyDate(),
          style: TextStyle(fontSize: 16),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Key message",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                plan.keyMessage,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        Text(
          "Problems",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        problemList,
        Text(
          "Turnaround time",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "${terrainPlan.turnaroundTime.format(context)} - ${terrainPlan.turnaroundPoint}",
          style: TextStyle(fontSize: 16),
        ),
        Text(
          "Checkin points",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: checkinPointList,
        ),
      ],
    );
  }
}
