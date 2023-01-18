import 'package:flutter/material.dart';
import 'package:dapurkuu/variable.dart';

class Tentang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 66,
          leadingWidth: 48,
          elevation: 0,
          backgroundColor: BGColor,
          title: Text("Tentang",
              style: TextStyle(fontWeight: FontWeight.bold, color: Black)),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                color: Black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_rounded),
              ),
            ],
          )),
      backgroundColor: BGColor,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sekilas tentang aplikasi ini:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Aplikasi Dapurku merupakan aplikasi yang dapat membantu kegiatan inventaris bahan pangan pada tingkat rumah tangga. Aplikasi ini memudahkan pengguna dalam menginventarisir bahan pangan yang ada di dapur pengguna. Aplikasi ini dibuat guna melengkapi sebagian syarat dalam mencapai gelar setara sarjana muda, yaitu Penulisan ilmiah.",
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      "Aplikasi ini dibuat oleh:",
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 200,
                      child: Text(
                        "Muhammad Rayhan Yovi 54419379",
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Dengan bimbingan:",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "Dr. Hustinawati, S.Kom, M.M.S.I.",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ]),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
