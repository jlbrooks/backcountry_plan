import 'package:flutter/material.dart';

class FormListScreen extends StatelessWidget {
  final String titleText;
  final String actionText;
  final Function(BuildContext) onAction;
  final List<Widget> children;
  final GlobalKey<FormState> formKey;
  final Future<bool> Function()? onWillPop;
  final Widget? floatingActionButton;

  FormListScreen({
    Key? key,
    required this.titleText,
    required this.actionText,
    required this.onAction,
    required this.children,
    required this.formKey,
    this.onWillPop,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      titleText: titleText,
      actionText: actionText,
      onAction: onAction,
      onWillPop: onWillPop,
      child: Form(
        key: formKey,
        child: ListView(
          physics: const ScrollPhysics(),
          children: children,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class ListScreen extends StatelessWidget {
  final String titleText;
  final String? actionText;
  final Function(BuildContext)? onAction;
  final List<Widget> children;
  final Future<bool> Function()? onWillPop;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  ListScreen({
    Key? key,
    required this.titleText,
    required this.children,
    this.actionText,
    this.onAction,
    this.actions,
    this.onWillPop,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      titleText: titleText,
      actionText: actionText,
      onAction: onAction,
      onWillPop: onWillPop,
      child: ListView(
        physics: const ScrollPhysics(),
        children: children,
      ),
      actions: actions,
      floatingActionButton: floatingActionButton,
    );
  }
}

class BasicScreen extends StatelessWidget {
  final String titleText;
  final String? actionText;
  final Function(BuildContext)? onAction;
  final Widget? child;
  final Future<bool> Function()? onWillPop;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  BasicScreen({
    Key? key,
    required this.titleText,
    this.actionText,
    this.onAction,
    this.child,
    this.onWillPop,
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget>? renderActions = [];
    if (actionText != null && onAction != null) {
      renderActions = [
        TextButton(
          child: Text(
            actionText!,
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => onAction!(context),
        )
      ];
    } else {
      renderActions = actions;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titleText),
          actions: renderActions,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: child,
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
