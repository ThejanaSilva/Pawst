import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vet & Community Forum')),
      body: Center(
        child: Text('Questions and vet answers will appear here.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open asking question dialog/screen
        },
        child: Icon(Icons.edit_document),
      ),
    );
  }
}
