// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables
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
  late Future<InventoryLine> _inventoryLine;
  final inventoryLineDB = InventoryLineDatabase.instance;

  @override
  void initState() {
    super.initState();
    _inventoryLine = inventoryLineDB.readBook(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InventoryLine>(
      future: _inventoryLine,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0,), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Text(snapshot.data!.item_name), 
                Icon(Icons.favorite), 
                Text(snapshot.data!.item_desc), 
                Text(snapshot.data!.in_stock.toString()),
              ],
            )
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      }, 
    );
  }
}