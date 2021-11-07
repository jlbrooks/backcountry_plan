import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/terrainPlan.dart';
import 'package:flutter/material.dart';

class NewTripRoutePage extends StatefulWidget {
  final TerrainPlanModel terrainPlan;
  NewTripRoutePage({Key? key, required this.terrainPlan}) : super(key: key);

  @override
  _NewTripRoutePageState createState() => _NewTripRoutePageState();
}

class _NewTripRoutePageState extends State<NewTripRoutePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController areasToAvoidController = TextEditingController();

  @override
  void initState() {
    super.initState();

    routeController.text = widget.terrainPlan.route;
    areasToAvoidController.text = widget.terrainPlan.areasToAvoid;
  }

  _onNext(BuildContext context) {}

  Future<bool> _onWillPop() async {
    widget.terrainPlan.route = routeController.text;
    widget.terrainPlan.areasToAvoid = areasToAvoidController.text;
    await TerrainPlanModelProvider().save(widget.terrainPlan);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FormColumnScreen(
      titleText: 'Plan to manage terrain',
      actionText: 'Next',
      onAction: _onNext,
      onWillPop: _onWillPop,
      formKey: formKey,
      children: [
        TitledSection(
          title: 'Terrain mindset',
          subTitle: "What's your terrain mindset for the trip?",
          child: TerrainMindsetInput(mindset: widget.terrainPlan.mindset),
        ),
        TextInputTitledSection(
          title: 'Route',
          subTitle: "Describe your route options that consider today's group, weather, and avalanche concerns.",
          hintText: 'Go up, ski down.',
          validationText: 'Please enter a route plan',
          controller: routeController,
          minLines: 5,
          maxLines: 10,
        ),
        TextInputTitledSection(
          title: 'Areas to avoid',
          subTitle: "Describe the types of terrain to avoid, based on the weather and avalanche concerns.",
          hintText: 'Sun-affected south-facing slopes',
          validationText: 'Please enter some areas to avoid',
          controller: areasToAvoidController,
          minLines: 5,
          maxLines: 10,
        ),
      ],
    );
  }
}
