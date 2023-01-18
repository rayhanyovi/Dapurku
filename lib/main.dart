import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapurkuu/petunjuk.dart';
import 'package:dapurkuu/tentang.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dapurkuu/variable.dart';
import 'package:dapurkuu/widget.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class BahanDapur {
  String id;
  final String nama;
  final int jumlah;
  final DateTime kadaluarsa;

  BahanDapur({
    this.id = '',
    required this.nama,
    required this.jumlah,
    required this.kadaluarsa,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'jumlah': jumlah,
        'kadaluarsa': kadaluarsa,
      };

  static BahanDapur fromJson(Map<String, dynamic> json) => BahanDapur(
        id: json['id'],
        nama: json['nama'],
        jumlah: json['jumlah'],
        kadaluarsa: (json['kadaluarsa'] as Timestamp).toDate(),
      );
}

//========================================================================================================================================//
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dapurku",
      home: Home(),
    );
  }
}

//========================================================================================================================================//
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CollectionReference _bahanDapur =
      FirebaseFirestore.instance.collection('bahanDapur');

  @override
  Widget build(BuildContext context) {
    Future CreateBahan(BahanDapur bahanDapur) async {
      final docUser = FirebaseFirestore.instance.collection('bahanDapur').doc();
      bahanDapur.id = docUser.id;
      final json = bahanDapur.toJson();
      await docUser.set(json);

      Future updateUser(BahanDapur bahanDapur) async {
        final docUser =
            FirebaseFirestore.instance.collection('bahanDapur').doc();
        bahanDapur.id = docUser.id;
        final json = bahanDapur.toJson();
        await docUser.update(json);
      }
    }

    Widget buildBahan(BahanDapur bahanDapur) {
      return Container(
        margin: EdgeInsets.only(
          right: 20,
          left: 20,
          bottom: 15,
        ),
        child: ListTile(
          contentPadding:
              EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          tileColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              bahanDapur.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jumlah: ${bahanDapur.jumlah}',
              ),
              Text(
                  'Kadaluarsa: ${DateFormat('dd MMMM yyyy').format(bahanDapur.kadaluarsa)}')
            ],
          ),
          trailing: Wrap(spacing: 0, children: [
            IconButton(
              icon: const Icon(Icons.edit),
              iconSize: 24,
              color: Colors.black,
              onPressed: () async {
                await Edit(context, CreateBahan, bahanDapur.id);
                setState(() {
                  updateName = TextEditingController(text: bahanDapur.nama);
                  updateAge =
                      TextEditingController(text: bahanDapur.jumlah.toString());
                  updateBirthday = TextEditingController(
                      text: bahanDapur.kadaluarsa.toString());
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              iconSize: 24,
              color: Colors.red,
              onPressed: () {
                final docUser = FirebaseFirestore.instance
                    .collection('bahanDapur')
                    .doc(bahanDapur.id);
                docUser.delete();
              },
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BGColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: BGColor,
        actions: [
          //list if widget in appbar actions
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Black,
            ), //don't specify icon if you want 3 dot menu
            color: Black,
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text(
                  "Petunjuk Penggunaan",
                  style: TextStyle(color: BGColor),
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text(
                  "Tentang",
                  style: TextStyle(color: BGColor),
                ),
              ),
            ],
            onSelected: (item) => SelectedItem(context, item),
          ),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Bahan Dapurmu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Black,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          StreamBuilder(
            stream: readBahan(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final bahanDapur = snapshot.data!;

                return Expanded(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: bahanDapur.map(buildBahan).toList(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  child: Text("data kosong"),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Black,
        onPressed: () async {
          await Create(context, CreateBahan);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Edit(BuildContext context, Future<dynamic> updateUser(BahanDapur bahanDapur),
      String id) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Ubah Informasi Bahan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                  controller: updateName,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                  ),
                  controller: updateAge,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: updateBirthday,
                  //editing controller of this TextField
                  decoration: const InputDecoration(
                      labelText: "Kadaluarsa" //label text of field
                      ),
                  readOnly: true,
                  //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2100));

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000 //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        updateBirthday.text = pickedDate
                            .toString(); //set output date to TextField value.
                      });
                    } else {}
                  },
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5.0,
                  child: Text("Ubah Data"),
                  onPressed: () {
                    final bahanDapur = BahanDapur(
                      id: id,
                      nama: updateName.text,
                      jumlah: int.parse(updateAge.text),
                      kadaluarsa: DateTime.parse(updateBirthday.text),
                    );
                    final docUser = FirebaseFirestore.instance
                        .collection('bahanDapur')
                        .doc(id)
                        .update(bahanDapur.toJson());

                    controllerJumlah.clear();
                    controllerKadaluarsa.clear();
                    controllerNama.clear();
                    Navigator.pop(context);
                    // updateUser(user;)
                  }),
            ],
          );
        });
  }

  Create(BuildContext context,
      Future<dynamic> CreateBahan(BahanDapur bahanDapur)) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tambahkan bahan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                  controller: controllerNama,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                  ),
                  controller: controllerJumlah,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: controllerKadaluarsa,
                  //editing controller of this TextField
                  decoration: InputDecoration(
                      labelText: "Kadaluarsa" //label text of field
                      ),
                  readOnly: true,
                  //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2100));

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000 //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        controllerKadaluarsa.text = pickedDate
                            .toString(); //set output date to TextField value.
                      });
                    } else {}
                  },
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5.0,
                  child: Text("Tambahkan"),
                  onPressed: () {
                    final bahanDapur = BahanDapur(
                      nama: controllerNama.text,
                      jumlah: int.parse(controllerJumlah.text),
                      kadaluarsa: DateTime.parse(controllerKadaluarsa.text),
                    );
                    CreateBahan(bahanDapur);
                    controllerJumlah.clear();
                    controllerKadaluarsa.clear();
                    controllerNama.clear();
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  Stream<List<BahanDapur>> readBahan() => FirebaseFirestore.instance
      .collection('bahanDapur')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => BahanDapur.fromJson(doc.data())).toList());
}

//========================================================================================================================================//
AppBar _AppBar() {
  return AppBar(
    elevation: 0,
    backgroundColor: BGColor,
    actions: [
      //list if widget in appbar actions
      PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Red,
        ), //don't specify icon if you want 3 dot menu
        color: Black,
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 0,
            child: Text(
              "Petunjuk Pnaan",
              style: TextStyle(color: BGColor),
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Text(
              "Tentang",
              style: TextStyle(color: BGColor),
            ),
          ),
        ],
        // onSelected: (item) => SelectedItem(context, item),
      ),
    ],
  );
}

void SelectedItem(BuildContext context, item) {
  switch (item) {
    case 0:
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Petunjuk()));
      break;
    case 1:
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Tentang()));
      break;
  }
}

//========================================================================================================================================//
class UpdateButton extends StatelessWidget {
  const UpdateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(Icons.edit),
        iconSize: 24,
        color: Colors.black,
        onPressed: () {},
      ),
    );
  }
}

//========================================================================================================================================//
// class SearchBox extends StatefulWidget {
//   const SearchBox({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<SearchBox> createState() => _SearchBoxState();
// }

// class _SearchBoxState extends State<SearchBox> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.only(left: 10),
//       child: TextField(
//         decoration: InputDecoration(
//             contentPadding: EdgeInsets.all(0),
//             prefixIcon: Icon(
//               Icons.search,
//               color: Black,
//               size: 20,
//             ),
//             prefixIconConstraints: BoxConstraints(
//               maxHeight: 20,
//               minWidth: 25,
//             ),
//             border: InputBorder.none,
//             hintText: "Cari Bahan...",
//             hintStyle: TextStyle(
//               color: Grey,
//             )),
//         onChanged: (value) {
//           setState(() {
//             var carinama = value;
//           });
//         },
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//     );
//   }
// }
