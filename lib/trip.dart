import 'package:backcountry_plan/components/common.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/screens/newTrip/newTrip.dart';
import 'package:backcountry_plan/screens/tripSummary/tripSummary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripListPage extends StatefulWidget {
  TripListPage({Key? key}) : super(key: key);

  @override
  TripListPageState createState() => TripListPageState();
}

class TripListPageState extends State<TripListPage> {
  List<TripModel> tripList = [];

  @override
  void initState() {
    super.initState();
    TripStore().all().then((trips) {
      trips.sort((a, b) => -a.date.compareTo(b.date));
      setState(() {
        this.tripList = trips;
      });
    });
  }

  _onTripPressed(BuildContext context, TripModel trip) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TripSummaryPage(trip: trip);
    }));
  }

  _onAddTripPressed(BuildContext context) async {
    await Navigator.push<TripModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return NewTripPage();
      }),
    );

    TripStore().all().then((trips) {
      trips.sort((a, b) => -a.date.compareTo(b.date));
      setState(() {
        this.tripList = trips;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var tripListView = DeleteableListView(
      list: this.tripList,
      confirmDeleteTitle: 'Delete trip?',
      confirmDeleteBodyBuilder: (TripModel item) => 'Are you sure you would like to delete trip \"${item.name}\"? This cannot be undone.',
      onDelete: (TripModel item, int index) {
        // Delete from database
        TripStore().delete(item);
        // Remove from the trip list
        setState(() {
          this.tripList.removeAt(index);
        });
      },
      itemBuilder: (TripModel item) => TripListItem(trip: item, onTapped: _onTripPressed),
    );

    return Scaffold(
      appBar: AppBar(title: Text('My trips')),
      body: tripListView,
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_onAddTripPressed(context)},
        tooltip: 'New trip',
        child: Icon(Icons.add),
      ),
    );
  }
}

class TripListItem extends StatelessWidget {
  final TripModel trip;
  final Function(BuildContext, TripModel) onTapped;

  TripListItem({Key? key, required this.trip, required this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(trip.name),
        subtitle: Text(trip.friendlyDate()),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          onTapped(context, trip);
        },
      ),
    );
  }
}

class EditTripPage extends StatefulWidget {
  final TripModel trip;
  EditTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tripNameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tripNameTextController.text = widget.trip.name;
  }

  _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.trip.date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        widget.trip.date = picked;
      });
    }
  }

  _onSave(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      widget.trip.name = tripNameTextController.text;
      await TripStore().save(widget.trip);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var titleText = widget.trip.isPersisted() ? 'Edit Trip' : 'New Trip';
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _onSave(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: tripNameTextController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Trip name',
                  hintText: 'Where are you headed?',
                ),
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      DateFormat.yMMMd().format(widget.trip.date),
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
            ],
          ),
        ),
      ),
    );
  }
}
