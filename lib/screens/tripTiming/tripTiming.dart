import 'package:backcountry_plan/screens/editCheckinPoint/editCheckinPoint.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:flutter/material.dart';

class TripTimingPage extends StatefulWidget {
  final TripModel trip;
  TripTimingPage({Key? key, required this.trip}) : super(key: key);

  @override
  _TripTimingPageState createState() => _TripTimingPageState(terrainPlan: trip.terrainPlan, checkinPoints: trip.checkinPoints);
}

class _TripTimingPageState extends State<TripTimingPage> {
  final TerrainPlanModel terrainPlan;
  final List<CheckinPointModel> checkinPoints;
  final TextEditingController turnaroundPointController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  _TripTimingPageState({required this.terrainPlan, required this.checkinPoints});

  @override
  void initState() {
    super.initState();
    turnaroundPointController.text = terrainPlan.turnaroundPoint;
  }

  _save() async {
    terrainPlan.turnaroundPoint = turnaroundPointController.text;
    await TripStore().save(widget.trip);
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      await _save();
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<bool> _onWillPop() async {
    await _save();
    return true;
  }

  Future<void> _showTurnaroundTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: terrainPlan.turnaroundTime,
    );
    if (picked != null) {
      setState(() {
        terrainPlan.turnaroundTime = picked;
      });
    }
  }

  _showEditCheckinPointPage(BuildContext context, CheckinPointModel? point) async {
    if (point == null) {
      point = CheckinPointModel.create();
    }
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditCheckinPointPage(checkinPoint: point!);
    }));

    if (result != null) {
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
        TripStore().save(widget.trip);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var checkinPointListView = DeleteableListView(
      list: checkinPoints,
      confirmDeleteTitle: 'Delete checkin point?',
      confirmDeleteBodyBuilder: (CheckinPointModel item) => 'Are you sure you would like to delete the checkin point at ${item.time.format(context)}?',
      onDelete: (CheckinPointModel item, int index) {
        // Remove from the trip list
        setState(() {
          checkinPoints.removeAt(index);
          TripStore().save(widget.trip);
        });
      },
      itemBuilder: (CheckinPointModel item) => CheckinPointListItem(point: item, onTapped: _showEditCheckinPointPage),
    );

    return FormListScreen(
      titleText: 'Trip timing',
      actionText: 'Save trip',
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
                  terrainPlan.turnaroundTime.format(context),
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
          child: checkinPointListView,
        ),
      ],
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
