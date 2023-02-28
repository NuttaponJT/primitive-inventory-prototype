// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, await_only_futures
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import "./models/catelog.dart";
import "./dbs/catelog.dart";
import "./pages/inventory_line_list.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catelog',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Catelog'),
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
  late Future<List<Catelog>> _Catelog;
  final CatelogDB = CatelogDatabase.instance;

  @override
  void initState() {
    super.initState();
    _Catelog = CatelogDB.readAllCatelog();
  }

  void _addCatelog() async {
    // ignore: unnecessary_new
    Random random = new Random();
    await CatelogDB.create(Catelog(
      categ_name: "Catelog ${random.nextInt(100)}",
    ));
    setState(() {
      _Catelog = CatelogDB.readAllCatelog();
    });
  }

  void showRenameCatelog(BuildContext context, int CatelogID) async {
    String input = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Catelog Name"),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Catelog catelog = await CatelogDB.readBook(CatelogID);
                await CatelogDB.updateColumn(catelog, {"categ_name": input});
                setState(() {
                  _Catelog = CatelogDB.readAllCatelog();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onLongPressCatelog(BuildContext context, int CatelogID) async {
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
                  Navigator.pop(context);
                  showRenameCatelog(context, CatelogID);
                },
                child: Container(
                  padding: EdgeInsets.all(16.0), 
                  child: Text("Rename"), 
                ), 
              ), 
              GestureDetector(
                onTap: () async {
                  await CatelogDB.delete(CatelogID);
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
      _Catelog = CatelogDB.readAllCatelog();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Catelog>>(
        future: _Catelog, 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(16.0), 
                  child: GestureDetector(
                    onLongPress: () {
                      onLongPressCatelog(context, snapshot.data![index].id ?? 0);
                    },
                    child: ListTile(
                      title: Text(snapshot.data![index].categ_name),
                      tileColor: Color.fromARGB(255, 255, 251, 217), 
                      onTap: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => InventoryLineListFrame(id: (snapshot.data![index].id ?? 0)), 
                          )
                        ).then((result) => {
                          setState(() {
                            _Catelog = CatelogDB.readAllCatelog();
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
        onPressed: _addCatelog,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
