import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:flutter/material.dart';

class NewTripHazardPage extends StatefulWidget {
  final TripModel trip;
  NewTripHazardPage({Key? key, required this.trip}) : super(key: key);

  @override
  _NewTripHazardPageState createState() => _NewTripHazardPageState();
}

class _NewTripHazardPageState extends State<NewTripHazardPage> {
  late PlanModel plan;
  final TextEditingController keyMessageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    PlanModelProvider().getByTripId(widget.trip.id!).then((plan) {
      if (plan != null) {
        this.plan = plan;
        this.keyMessageTextController.text = plan.keyMessage;
      } else {
        this.plan = PlanModel.newForTrip(widget.trip.id!);
        PlanModelProvider().save(this.plan);
      }
    });
  }

  _onNext(BuildContext context) async {}

  Future<bool> _onWillPop() async {
    this.plan.keyMessage = keyMessageTextController.text;
    PlanModelProvider().save(this.plan);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      titleText: 'Hazards',
      actionText: 'Next',
      onAction: _onNext,
      onWillPop: _onWillPop,
      child: Column(
        children: [
          TextInputTitledSection(
            title: 'Key message',
            subTitle: "What is the avalanche advisory's key message?",
            hintText: 'Stay off of sun-affected southern aspects',
            validationText: 'Please enter a key message',
            controller: keyMessageTextController,
          ),
        ],
      ),
    );
  }
}
