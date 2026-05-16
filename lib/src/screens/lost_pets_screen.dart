import 'package:flutter/material.dart';

class LostPetsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lost Pets')),
      body: Center(
        child: Text('Lost pets listings and reports will appear here.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add lost pet report flow
        },
        icon: Icon(Icons.campaign),
        label: Text('Report Lost Pet'),
      ),
    );
  }
}
