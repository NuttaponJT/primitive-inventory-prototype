// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import "../models/inventory_line.dart";
import "../dbs/inventory_line.dart";

import "../pages/inventory_line.dart";

class InventoryLineListFrame extends StatelessWidget {
  final int id;
  
  InventoryLineListFrame({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Line List"),
      ),
      body: InventoryLineListPage(id: id), 
    );
  }
}

class InventoryLineListPage extends StatefulWidget {
  final int id;
  const InventoryLineListPage({required this.id});

  @override
  State<InventoryLineListPage> createState() => _InventoryLineListPage();
}

class _InventoryLineListPage extends State<InventoryLineListPage> {
  late Future<List<InventoryLine>> _inventoryLines;
  final inventoryLineDB = InventoryLineDatabase.instance;

  @override
  void initState() {
    super.initState();
    _inventoryLines = inventoryLineDB.readInventoryLineByCateg(widget.id);
  }

  void _addInventoryLine() async {
    // ignore: unnecessary_new
    Random random = new Random();
    await inventoryLineDB.create(InventoryLine(
      item_name: "Item ${random.nextInt(100)}",
      item_desc: "Item ${random.nextInt(100)} Description",
      in_stock: 1,
      image_path: "", 
      categ_id: widget.id, 
    ));
    setState(() {
      _inventoryLines = inventoryLineDB.readInventoryLineByCateg(widget.id);
    });
  }

  void showRenameInventoryLine(BuildContext context, int inventoryLineID) async {
    String input = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter item Name"),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                InventoryLine inventoryLine = await inventoryLineDB.readBook(inventoryLineID);
                await inventoryLineDB.updateColumn(inventoryLine, {"item_name": input});
                setState(() {
                  _inventoryLines = inventoryLineDB.readAllInventoryLine();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onLongPressInventoryLine(BuildContext context, int inventoryLineID) async {
    await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  showRenameInventoryLine(context, inventoryLineID);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(16.0), 
                  child: Text("Delete Item"), 
                ), 
              ), 
              GestureDetector(
                onTap: () async {
                  await inventoryLineDB.delete(inventoryLineID);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(16.0), 
                  child: Text("Delete Item"), 
                ), 
              ), 
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(16.0), 
                  child: Text("Cancel"), 
                ), 
              ), 
            ],
          ), 
        );
      }, 
    );
    setState(() {
      _inventoryLines = inventoryLineDB.readInventoryLineByCateg(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<List<InventoryLine>>(
        future: _inventoryLines, 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(16.0), 
                  child: GestureDetector(
                    onLongPress: () {
                      onLongPressInventoryLine(context, snapshot.data![index].id ?? 0);
                    },
                    child: ListTile(
                      title: Text(snapshot.data![index].item_name),
                      subtitle: Text(snapshot.data![index].item_desc),
                      leading: Container(
                        child: snapshot.data![index].image_path == ""
                          ? Icon(Icons.add_a_photo)
                          : Image.file(
                            File(snapshot.data![index].image_path),
                            fit: BoxFit.contain,
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
                            _inventoryLines = inventoryLineDB.readInventoryLineByCateg(widget.id);
                          })
                        });
                      }, 
                    ),
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