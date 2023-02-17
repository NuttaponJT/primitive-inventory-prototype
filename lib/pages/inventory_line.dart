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
  late int inStock;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  bool _isEditInStock = false;

  @override
  void initState() {
    super.initState();
    _inventoryLine = inventoryLineDB.readBook(widget.id);
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void onClickDecreaseButton() async {
    InventoryLine inventoryLine = await _inventoryLine;
    await inventoryLineDB.updateColumn(inventoryLine, {"in_stock": inStock - 1});
    setState(() {
      _inventoryLine = inventoryLineDB.readBook(widget.id);
    });
  }
  
  void onClickIncreaseButton() async {
    InventoryLine inventoryLine = await _inventoryLine;
    await inventoryLineDB.updateColumn(inventoryLine, {"in_stock": inStock + 1});
    setState(() {
      _inventoryLine = inventoryLineDB.readBook(widget.id);
    });
  }

  void onSubmittedNumber(number) async {
    InventoryLine inventoryLine = await _inventoryLine;
    await inventoryLineDB.updateColumn(inventoryLine, {"in_stock": int.parse(number)});
    setState(() {
      _isEditInStock = false;
      _inventoryLine = inventoryLineDB.readBook(widget.id);
    });
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    InventoryLine inventoryLine = await _inventoryLine;
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = "${inventoryLine.item_name}.jpg";
    final appFilePath = join(appDir.path, fileName);
    await File(image!.path).copy("${appFilePath}");
    await inventoryLineDB.updateColumn(inventoryLine, {"image_path": appFilePath});
    setState(() {
      _inventoryLine = inventoryLineDB.readBook(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InventoryLine>(
      future: _inventoryLine,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          inStock = snapshot.data!.in_stock;
          return Scaffold(
            body: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0,), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, 
                crossAxisAlignment: CrossAxisAlignment.center, 
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft, 
                    child: Text(snapshot.data!.item_name),
                  ), 
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.35,
                    child: GestureDetector(
                      onTap: pickImage, 
                      child: snapshot.data!.image_path == ""
                        ? Icon(Icons.add_a_photo)
                        : Image.file(
                          File(snapshot.data!.image_path),
                          fit: BoxFit.cover,
                        ), 
                    ), 
                  ), 
                  Align(
                    alignment: Alignment.centerLeft, 
                    child: Text(snapshot.data!.item_desc),
                  ), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 35, 
                        height: 35, 
                        child: ElevatedButton(
                          onPressed: onClickDecreaseButton, 
                          child: Text(
                            "-", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ), 
                          ),
                        ),
                      ),  
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0), 
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              _isEditInStock = true;
                              _textEditingController.text = snapshot.data!.in_stock.toString();
                              _focusNode.requestFocus();
                            });
                          }, 
                          child: !_isEditInStock
                            ? Text(
                              snapshot.data!.in_stock.toString(), 
                              style: TextStyle(
                                fontSize: 20.0, 
                                fontWeight: FontWeight.bold, 
                              )
                            )
                            : Container(
                              width: 30,
                              child: TextField(
                                controller: _textEditingController, 
                                keyboardType: TextInputType.number, 
                                focusNode: _focusNode,
                                onSubmitted: onSubmittedNumber
                              ),
                            ), 
                        ),  
                      ), 
                      SizedBox(
                        width: 35, 
                        height: 35, 
                        child: ElevatedButton(
                          onPressed: onClickIncreaseButton, 
                          child: Text(
                            "+", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ), ),
                        ),
                      ),
                    ],
                  ), 
                ],
              )
            ), 
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      }, 
    );
  }
}