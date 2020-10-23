import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.orange),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input = "";
  createTodos(input) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyToDos").doc(input);
    Map<String, String> todos = {"todotitle": input};
    documentReference.set(todos).whenComplete(() {
      print("$input created");
    });
  }

  deleteTodos(input) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyToDos").doc(input);
    documentReference.delete().whenComplete(() {
      print("$input deleted");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My To-Do's"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Add to List"),
                    content: TextField(
                      onChanged: (String value) {
                        input = value;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            createTodos(input);
                            Navigator.of(context).pop();
                          },
                          child: Text("Add"))
                    ],
                  );
                });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection("MyToDos").snapshots(),
            builder: (context, snapshots) {
              if (snapshots.data == null) return CircularProgressIndicator();
              return ListView.builder(
                  itemCount: snapshots.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshots.data.documents[index];
                    return Dismissible(
                      key: UniqueKey(),
                      child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Text(documentSnapshot["todotitle"]),
                            trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteTodos(documentSnapshot['todotitle']);
                                }),
                          )),
                      onDismissed: (DismissDirection right) {
                        deleteTodos(documentSnapshot['todotitle']);
                      },
                    );
                  });
            }));
  }
}
