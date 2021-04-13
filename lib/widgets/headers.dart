import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String name;

  const SectionHeader(this.name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("$name"),
      dense: true,
      enabled: false,
    );
  }
}
