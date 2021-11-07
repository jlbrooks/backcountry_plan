import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/plan.dart';
import 'package:backcountry_plan/screens/newTrip/newTrip.dart';
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
    TripModelProvider().all().then((trips) {
      trips.sort((a, b) => -a.date.compareTo(b.date));
      setState(() {
        this.tripList = trips;
      });
    });
  }

  _onTripPressed(BuildContext context, TripModel trip) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TripPage(trip: trip);
    }));
  }

  _onAddTripPressed(BuildContext context) async {
    await Navigator.push<TripModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return NewTripPage();
      }),
    );

    TripModelProvider().all().then((trips) {
      trips.sort((a, b) => -a.date.compareTo(b.date));
      setState(() {
        this.tripList = trips;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var tripListView = ListView.builder(
      itemCount: this.tripList.length,
      itemBuilder: (context, index) {
        final item = this.tripList[index];
        return Dismissible(
          key: Key(item.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete trip?'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text("Are you sure you would like to delete trip \"${item.name}\"? This cannot be undone."),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) async {
            // Delete from database
            TripModelProvider().delete(item);
            // Remove from the trip list
            setState(() {
              tripList.removeAt(index);
            });
          },
          background: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: TripListItem(trip: item, onTapped: _onTripPressed),
        );
      },
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
      await TripModelProvider().save(widget.trip);
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

class TripPage extends StatefulWidget {
  final TripModel trip;

  TripPage({Key? key, required this.trip}) : super(key: key);

  @override
  TripPageState createState() => TripPageState(trip: trip);
}

class TripPageState extends State<TripPage> {
  final TripModel trip;
  PlanModel? plan;

  TripPageState({required this.trip});

  @override
  void initState() {
    PlanModelProvider().getByTripId(trip.id!).then((_plan) {
      setState(() {
        plan = _plan;
      });
    });
    super.initState();
  }

  _onEdit(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditTripPage(trip: trip);
    }));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _onEdit(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [PlanSummary(plan: plan, onNavigateToPlan: _navigateAndEditPlan)],
        ),
      ),
    );
  }

  _navigateAndEditPlan(BuildContext context) async {
    if (plan == null) {
      plan = PlanModel(tripId: trip.id!, keyMessage: '', forecast: '');
      await PlanModelProvider().save(plan!);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return PlanPage(plan: plan!);
      }),
    );
    if (result != null) {
      PlanModelProvider().save(plan!);
      setState(() {
        plan = plan;
      });
    }
  }
}

class PlanSummary extends StatelessWidget {
  final PlanModel? plan;
  final Function(BuildContext) onNavigateToPlan;

  PlanSummary({required this.plan, required this.onNavigateToPlan});

  @override
  Widget build(BuildContext context) {
    if (plan == null) {
      return ElevatedButton(
        onPressed: () {
          onNavigateToPlan(context);
        },
        child: Text('Create plan'),
      );
    } else {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.vpn_key),
              title: Text('Key Message:'),
              subtitle: Text(plan!.keyMessage),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                onNavigateToPlan(context);
              },
            ),
          ],
        ),
      );
    }
  }
}
