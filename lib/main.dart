// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import "./models/inventory_line.dart";
import "./dbs/inventory_line.dart";
import "./pages/inventory_line.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Inventory'),
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
      image_path: "", 
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
                return Container(
                  padding: EdgeInsets.all(16.0), 
                  child: ListTile(
                    title: Text(snapshot.data![index].item_name),
                    subtitle: Text(snapshot.data![index].item_desc),
                    leading: Container(
                      child: GestureDetector( 
                        child: snapshot.data![index].image_path == ""
                          ? Icon(Icons.add_a_photo)
                          : Image.file(
                            File(snapshot.data![index].image_path),
                            fit: BoxFit.contain,
                          ), 
                      ), 
                    ), 
                    tileColor: Color.fromARGB(255, 255, 251, 217), 
                    onTap: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => InventoryLineFrame(id: (snapshot.data![index].id ?? 0)), 
                        )
                      ).then((result) => {
                        setState(() {
                          _inventoryLines = inventoryLineDB.readAllInventoryLine();
                        })
                      });
                    }, 
                  )
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
