import 'package:backcountry_plan/checkinPoint.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/terrainPlan.dart';
import 'package:flutter/material.dart';

class NewTripTimingPage extends StatefulWidget {
  final TerrainPlanModel terrainPlan;
  NewTripTimingPage({Key? key, required this.terrainPlan}) : super(key: key);

  @override
  _NewTripTimingPageState createState() => _NewTripTimingPageState();
}

class _NewTripTimingPageState extends State<NewTripTimingPage> {
  final TextEditingController turnaroundPointController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<CheckinPointModel> checkinPoints = [];

  @override
  void initState() {
    super.initState();
    turnaroundPointController.text = widget.terrainPlan.turnaroundPoint;

    CheckinPointModelProvider().getByTerrainPlanId(widget.terrainPlan.id!).then((_points) {
      setState(() {
        checkinPoints = _points;
        checkinPoints.sort((a, b) => a.compareTo(b));
      });
    });
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {}
  }

  Future<bool> _onWillPop() async {
    this.widget.terrainPlan.turnaroundPoint = turnaroundPointController.text;
    await TerrainPlanModelProvider().save(widget.terrainPlan);
    return true;
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
      await CheckinPointModelProvider().save(result);
      setState(() {
        var index = checkinPoints.indexOf(result);
        // When the point was already in the list
        if (index >= 0) {
          checkinPoints[index] = result;
        }
        // When it's a new point
        else {
          checkinPoints.add(result);
        }
        checkinPoints.sort((a, b) => a.compareTo(b));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var checkinPointList = ListView.builder(
      itemCount: checkinPoints.length,
      itemBuilder: (context, index) => CheckinPointListItem(point: checkinPoints[index], onTapped: _showEditCheckinPointPage),
    );

    return FormColumnScreen(
      titleText: 'Trip timing',
      actionText: 'Next',
      onAction: _onNext,
      onWillPop: _onWillPop,
      formKey: formKey,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {_showEditCheckinPointPage(context, null)},
        label: Text('Add checkin point'),
        icon: Icon(Icons.add),
      ),
      children: [
        TextInputTitledSection(
          title: 'Turnaround point',
          subTitle: 'Describe your turnaround point.',
          hintText: 'The top of the mountain',
          validationText: 'Please enter a turnaround point description',
          controller: turnaroundPointController,
          minLines: 3,
          maxLines: 5,
        ),
        TitledSection(
          title: 'Turnaround time',
          subTitle: "What's the drop-dead turnaround time?",
          child: Row(
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
          ),
        ),
        TitledSection(
          title: 'Checkin points',
          subTitle: 'What are the checkin points along the way?',
        ),
        Expanded(
          child: checkinPointList,
        ),
      ],
    );
  }
}
