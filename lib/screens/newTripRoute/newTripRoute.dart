import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/screens/newTripTiming/newTripTiming.dart';
import 'package:flutter/material.dart';

class NewTripRoutePage extends StatefulWidget {
  final TripModel trip;
  NewTripRoutePage({Key? key, required this.trip}) : super(key: key);

  @override
  _NewTripRoutePageState createState() => _NewTripRoutePageState(terrainPlan: trip.terrainPlan);
}

class _NewTripRoutePageState extends State<NewTripRoutePage> {
  final TerrainPlanModel terrainPlan;
  final formKey = GlobalKey<FormState>();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController areasToAvoidController = TextEditingController();

  _NewTripRoutePageState({required this.terrainPlan});

  @override
  void initState() {
    super.initState();

    routeController.text = terrainPlan.route;
    areasToAvoidController.text = terrainPlan.areasToAvoid;
  }

  _save() async {
    terrainPlan.route = routeController.text;
    terrainPlan.areasToAvoid = areasToAvoidController.text;
    await TripStore().save(widget.trip);
  }

  _onNext(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      await _save();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NewTripTimingPage(trip: widget.trip);
      }));
    }
  }

  Future<bool> _onWillPop() async {
    await _save();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FormListScreen(
      titleText: 'Plan to manage terrain',
      actionText: 'Next',
      onAction: _onNext,
      onWillPop: _onWillPop,
      formKey: formKey,
      children: [
        TitledSection(
          title: 'Terrain mindset',
          subTitle: "What's your terrain mindset for the trip?",
          child: TerrainMindsetInput(mindset: terrainPlan.mindset),
        ),
        TextInputTitledSection(
          title: 'Route',
          subTitle: "Describe your route options that consider today's group, weather, and avalanche concerns. Note any important precautions on the route.",
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
