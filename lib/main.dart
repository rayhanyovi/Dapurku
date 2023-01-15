import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dapurkuu/warna.dart';
import 'package:dapurkuu/widget.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

//========================================================================================================================================//
const Color Red = Color(0xFFDA4040);
const Color Blue = Color(0xFF5F52EE);
const Color Black = Color(0xFF3A3A3A);
const Color Grey = Color(0xFF717171);
const Color BGColor = Color(0xFFEEEFF5);

final controllerName = TextEditingController();
final controllerAge = TextEditingController();
final controllerBirthday = TextEditingController();

TextEditingController updateName = TextEditingController();
TextEditingController updateAge = TextEditingController();
TextEditingController updateBirthday = TextEditingController();

//========================================================================================================================================//
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
      title: "Test",
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
    Future createUser(BahanDapur bahanDapur) async {
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

    Widget buildUser(BahanDapur bahanDapur) {
      return Container(
        margin: EdgeInsets.only(
          right: 20,
          left: 20,
          bottom: 15,
        ),
        child: Material(
          child: ListTile(
            onTap: () {
              print("card");
            },
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
                  await Edit(context, createUser, bahanDapur.id);
                  setState(() {
                    updateName = TextEditingController(text: bahanDapur.nama);
                    updateAge = TextEditingController(
                        text: bahanDapur.jumlah.toString());
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: BGColor,
      appBar: _AppBar(),
      body: Column(
        children: [
          /* JUDUL */
          Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: SearchBox()),
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
          /* STREAM BUILDER */

          StreamBuilder(
              stream: readUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final bahanDapur = snapshot.data!;

                  return Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: bahanDapur.map(buildUser).toList(),
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
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Create(context, createUser);
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
            title: Text("Edit bahan"),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                  controller: updateName,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Umur',
                  ),
                  controller: updateAge,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: updateBirthday,
                  //editing controller of this TextField
                  decoration: const InputDecoration(
                      labelText: "Enter Date" //label text of field
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
                    // updateUser(user;)
                  }),
            ],
          );
        });
  }

  Create(BuildContext context,
      Future<dynamic> createUser(BahanDapur bahanDapur)) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tambahkan bahan"),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                  controller: controllerName,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Umur',
                  ),
                  controller: controllerAge,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: controllerBirthday,
                  //editing controller of this TextField
                  decoration: InputDecoration(
                      labelText: "Enter Date" //label text of field
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
                        controllerBirthday.text = pickedDate
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
                      nama: controllerName.text,
                      jumlah: int.parse(controllerAge.text),
                      kadaluarsa: DateTime.parse(controllerBirthday.text),
                    );
                    createUser(bahanDapur);
                  }),
            ],
          );
        });
  }

  Stream<List<BahanDapur>> readUsers() => FirebaseFirestore.instance
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
    title: Center(
      child: Text(
        "Dapurku",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Black,
        ),
      ),
    ),
  );
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
class SearchBox extends StatelessWidget {
  const SearchBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: const TextField(
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: Black,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(
              maxHeight: 20,
              minWidth: 25,
            ),
            border: InputBorder.none,
            hintText: "Cari Bahan...",
            hintStyle: TextStyle(
              color: Grey,
            )),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
