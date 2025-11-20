import 'package:expense_tracker/utils/dataPersistence.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, List> items = {};
  File? jsonFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await initializeStorage();
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    final loadedData = await dataPersistence.loadFromjson();
    if (loadedData != null) {
      setState(() {
        items = Map<String, List>.from(loadedData);
      });
    }
  }

  Future<void> _saveData() async {
    await dataPersistence.saveTojson(items);
  }

  // Future<void> initializeStorage() async {
  //   final appfolder = await addFolder();
  //   print("\n\ncreating json in initializeStorage\n\n");
  //   setState(() {
  //     jsonFile = File("${appfolder?.path}/data.json");
  //   });
  //   print(jsonFile);
  // }

  // Future<Directory?> addFolder() async {
  //   Directory? appDir = await getExternalStorageDirectory();
  //   var folderName = "Expense Tracker";
  //   if (appDir != null) {
  //     Directory appFolder = Directory("${appDir.path}/$folderName");
  //     if (!await appFolder.exists()) {
  //       appFolder.create(recursive: true);
  //       print("\nfolder created!!\n");
  //     }
  //     print("\nfolder returned\n");
  //     return appFolder;
  //   } else {
  //     print("\nadd folder returned null\n");
  //     return null;
  //   }
  // }

  // Future<void> loadFromjson() async {
  //   if (jsonFile == null) return;

  //   if (await jsonFile!.exists()) {
  //     print("\nso he found the json file and now loading\n");
  //     final String jsonData = await jsonFile!.readAsString();
  //     // print(jsonData.runtimeType);
  //     final itemsmap = await jsonDecode(jsonData);

  //     setState(() {
  //       items = Map<String, List>.from(itemsmap);
  //     });
  //     // final List soundmap = jsonDecode(jsonData) as List<dynamic>;
  //     // final loadedsounds =
  //     //     soundmap
  //     //         .map(
  //     //           (element) => Buttons(
  //     //             element["path"] as String,
  //     //             element["label"] as String,
  //     //           ),
  //     //         )
  //     //         .toList();
  //     // setState(() {
  //     //   sounds = loadedsounds;
  //     // });
  //   } else {
  //     await saveTojson();
  //   }
  // }

  // Future<void> saveTojson() async {
  //   if (jsonFile == null) return;
  //   try {
  //     final String jsonData = jsonEncode(items);
  //     // final List soundsmap =
  //     //     sounds.map((btn) => {"path": btn.path, "label": btn.label}).toList();
  //     // final String jsonData = jsonEncode(soundsmap);
  //     await jsonFile!.writeAsString(jsonData);
  //     print("\nohh it didn't find an issuse saving the json\n");
  //     setState(() {});
  //   } catch (e) {
  //     print("\noops error happend in saving the json\n");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        child: IconButton(
          onPressed: () async {
            DateTime now = DateTime.now();
            String formated = DateFormat("EE, y/M/d").format(now);
            setState(() {
              items[formated] ??= [];
            });
            await _saveData();
          },
          icon: Icon(Icons.add, size: 40, color: Colors.white),
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(CircleBorder()),
            fixedSize: WidgetStatePropertyAll(Size.fromRadius(32)),
            backgroundColor: WidgetStatePropertyAll(Color(0xFF769FCD)),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Expense Tracker",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 58, 128, 249),
        elevation: 3,
        shadowColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var name = items.keys.toList()[index];
            return TextButton(
              onPressed: () async {
                final updatedData = await Navigator.pushNamed(
                  context,
                  "/details",
                  arguments: {"name": name, "data": items},
                );
                await _saveData();
                print(items);
                print(updatedData);
                // print(items);
                // if (updatedData != null) {
                //   final newdata = updatedData as Map;
                //   print(items[newdata["name"]]);
                //   print(newdata["items"]);

                //   newdata["items"].forEach((item) {
                //   });
                //   setState(() {
                //     items[name]?.addAll(item);
                //     items[name]?.addAll(newdata["items"]);
                //   });

                //   print(items[newdata["name"]]);
                // }
              },
              child: Text(name, style: TextStyle(fontSize: 18)),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 176, 201, 242)),
              ),
            );
          },
        ),
      ),
    );
  }
}
