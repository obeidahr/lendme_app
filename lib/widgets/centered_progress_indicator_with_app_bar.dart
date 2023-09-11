import 'package:flutter/material.dart';

class CenteredCircularProgressIndicatorWithAppBar extends StatelessWidget {
  const CenteredCircularProgressIndicatorWithAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lend Me")),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
