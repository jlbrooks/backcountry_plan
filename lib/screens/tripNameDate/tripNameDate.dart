import 'package:backcountry_plan/common.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/screens/tripHazard/tripHazard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripNameDatePage extends StatefulWidget {
  final TripModel trip;
  final bool isNewTripWizard;

  TripNameDatePage({required this.trip, required this.isNewTripWizard});

  @override
  _TripNameDatePageState createState() => _TripNameDatePageState();
}

class _TripNameDatePageState extends State<TripNameDatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tripNameTextController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    tripNameTextController.text = widget.trip.name;
    selectedDate = widget.trip.date.clone();
  }

  _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _onNext(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      widget.trip.name = tripNameTextController.text;
      widget.trip.date = selectedDate;
      await TripStore().save(widget.trip);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TripHazardPage(trip: widget.trip);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    var titleText = widget.isNewTripWizard ? 'New trip' : 'Edit trip';
    return FormListScreen(
      titleText: titleText,
      actionText: 'Next',
      onAction: _onNext,
      formKey: _formKey,
      children: <Widget>[
        TextInputTitledSection(
          title: 'Where are you headed?',
          subTitle: 'This is the name of your trip',
          hintText: 'Mt. Everest',
          validationText: 'Please enter a name',
          controller: tripNameTextController,
        ),
        TitledSection(
          title: 'When is the trip?',
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  DateFormat.yMMMd().format(selectedDate),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDatePicker(context),
                  child: Text('Change date'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
