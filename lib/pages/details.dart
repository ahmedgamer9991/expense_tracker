import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/utils/dataPersistence.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> with WidgetsBindingObserver {
  Map<String, List> data = {}; // Now a Map<String, List>
  String date = "";
  List items = [];
  // String? date;
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  int? editingRow;
  TextEditingController? _itemController;
  TextEditingController? _priceController;
  String? _originalItem;
  double? _originalPrice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // print(date);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = await ModalRoute.of(context)!.settings.arguments as Map;
      final datas = args["data"];
      print(["args", args]);
      setState(() {
        date = args["name"];
        items = datas[date];
        data = datas;
      });
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final args = ModalRoute.of(context)!.settings.arguments as Map;
    //   final date = args.keys.first;
    //   final items = args[date];
    //   setState(() {
    //     data = {date: List.from(items ?? [])};
    //   });
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _itemController?.dispose();
    _priceController?.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(["state", state]);
    if (state == AppLifecycleState.paused) {
      dataPersistence.saveTojson(data);
    }
  }

  void submit(String item, String price) async {
    setState(() {
      if (editingRow != null) {
        items[editingRow!] = [item, double.tryParse(price) ?? 0];
        editingRow = null;
      } else {
        items.add([item, double.tryParse(price) ?? 0]);
      }
    });
    // print(["submit", data]);
    await dataPersistence.saveTojson(data);
  }

  void deleteRow(int index) async {
    setState(() {
      items.removeAt(index);
    });
    await dataPersistence.saveTojson(data);
  }

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item[1] as double;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // print(date);
    // final args = ModalRoute.of(context)!.settings.arguments as Map;
    // final datas = args["data"];
    // final date = args["name"];
    // final items = datas[date];
    // print(["args",args]);
    // setState(() {
    //   data = datas;
    // });
    // print(["data", data]);
    // print(["date", date]);
    // print(["items", items]);
    // final date = data.keys.first;

    // data = ModalRoute.of(context)?.settings.arguments as Map;
    // final date = data.keys.first;
    // final items = data[date];

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        child: IconButton(
          onPressed: () {
            _showDialog(context);
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
        leading: IconButton(
          onPressed: () async {
            print(["appbar", data]);
            await dataPersistence.saveTojson(data);
            Navigator.pop(context, data);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          date,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 58, 128, 249),
        elevation: 3,
        shadowColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: screenWidth),
                  child: DataTable(
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    border: TableBorder(
                      verticalInside: BorderSide(color: Colors.grey.shade400),
                      bottom: BorderSide(color: Colors.grey.shade400),
                    ),
                    // columnSpacing: 3,
                    headingRowColor: WidgetStatePropertyAll(
                      Color.fromARGB(255, 176, 201, 242),
                    ),
                    dataTextStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    columns: [
                      DataColumn(label: Text("Item")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: [
                      ...List<DataRow>.generate(items.length, (index) {
                        final item = items[index][0];
                        final price = items[index][1];
                        bool isEditing = editingRow == index;
                        return DataRow(
                          cells: [
                            DataCell(
                              isEditing
                                  ? TextField(
                                    controller: _itemController,
                                    focusNode: _focusNode1,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  )
                                  : Text(item),
                            ),
                            DataCell(
                              isEditing
                                  ? TextField(
                                    controller: _priceController,
                                    focusNode: _focusNode2,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  )
                                  : Text(price.toString()),
                            ),
                            DataCell(
                              isEditing
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () async {
                                          setState(() {
                                            // Save current values from controllers
                                            if (_itemController != null) {
                                              items[index][0] =
                                                  _itemController!.text;
                                            }
                                            if (_priceController != null) {
                                              final parsed = double.tryParse(
                                                _priceController!.text,
                                              );
                                              if (parsed != null) {
                                                items[index][1] = parsed;
                                              }
                                            }

                                            // Cleanup
                                            _itemController?.dispose();
                                            _priceController?.dispose();
                                            _itemController = null;
                                            _priceController = null;
                                            editingRow = null;
                                          });
                                          await dataPersistence.saveTojson(
                                            data,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel),
                                        onPressed: () async {
                                          setState(() {
                                            // Revert changes
                                            items[index][0] = _originalItem;
                                            items[index][1] = _originalPrice;

                                            // Cleanup
                                            _itemController?.dispose();
                                            _priceController?.dispose();
                                            _itemController = null;
                                            _priceController = null;
                                            editingRow = null;
                                          });
                                          await dataPersistence.saveTojson(
                                            data,
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 23),
                                        onPressed: () {
                                          setState(() {
                                            editingRow = index;
                                            _originalItem = item;
                                            _originalPrice = price;
                                            _itemController =
                                                TextEditingController(
                                                  text: item,
                                                );
                                            _priceController =
                                                TextEditingController(
                                                  text: price.toString(),
                                                );
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 23,
                                        ),
                                        onPressed: () => deleteRow(index),
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        );
                      }),
                      DataRow(
                        color: WidgetStatePropertyAll(
                          Color.fromARGB(255, 176, 201, 242),
                        ),
                        cells: [
                          DataCell(
                            Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              calculateTotal().toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Container()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    String? item;
    String? price;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 3,
          ),
          title: Text("Add new"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                // maxLength: 30,
                focusNode: _focusNode1,
                onTapOutside: (event) {
                  _focusNode1.unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Item",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  item = value;
                },
              ),
              SizedBox(height: 15),
              TextField(
                // maxLength: 30,
                keyboardType: TextInputType.number,
                focusNode: _focusNode2,
                onTapOutside: (event) {
                  _focusNode2.unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  price = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (item != null && price != null) {
                  submit(item!, price!);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
