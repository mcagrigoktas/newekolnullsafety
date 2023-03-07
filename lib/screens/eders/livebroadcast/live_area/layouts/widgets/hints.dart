import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Hints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [16.heightBox, const Icon(Icons.info, size: 32, color: Colors.amber), 16.heightBox, Text('livelessonspacehint'.translate, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xffBBC7DE), fontSize: 12))],
    );
  }
}
