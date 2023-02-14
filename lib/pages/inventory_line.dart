// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

import "../models/inventory_line.dart";
import "../dbs/inventory_line.dart";

class InventoryLineFrame extends StatelessWidget {
  final int id;
  
  InventoryLineFrame({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Line"),
      ),
      body: InventoryLinePage(id: id), 
    );
  }
}

class InventoryLinePage extends StatefulWidget {
  final int id;
  const InventoryLinePage({required this.id});

  @override
  State<InventoryLinePage> createState() => _InventoryLinePage();
}

class _InventoryLinePage extends State<InventoryLinePage> {

}
