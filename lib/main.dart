// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

import "./models/inventory_line.dart";
import "./dbs/inventory_line.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<InventoryLine>> _inventoryLines;
  final inventoryLineDB = InventoryLineDatabase.instance;

  @override
  void initState() {
    super.initState();
    _inventoryLines = inventoryLineDB.readAllInventoryLine();
  }

  void _addInventoryLine() async {
    // ignore: unnecessary_new
    Random random = new Random();
    await inventoryLineDB.create(InventoryLine(
      item_name: "Item ${random.nextInt(100)}",
      item_desc: "Item ${random.nextInt(100)} Description",
      in_stock: 1,
    ));
    setState(() {
      _inventoryLines = inventoryLineDB.readAllInventoryLine();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<InventoryLine>>(
        future: _inventoryLines, 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].item_name),
                  subtitle: Text(snapshot.data![index].item_desc),
                  tileColor: Color.fromARGB(255, 255, 251, 217), 
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: _addInventoryLine,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
