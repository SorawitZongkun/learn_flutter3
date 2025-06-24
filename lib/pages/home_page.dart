// Step 2: make a home page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter4/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Step 3: make a FirestoreService
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog vox to add a note
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(controller: textController),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // add a new note
                  // firestoreService.addNote(textController.text);

                  // Step 5: make an update function
                  if (docID != null) {
                    // update the note
                    firestoreService.updateNote(docID, textController.text);
                  } else {
                    // add a new note
                    firestoreService.addNote(textController.text);
                  }

                  // clear the text controller
                  textController.clear();

                  // close the box
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNoteBox();
        },
        child: Icon(Icons.add),
      ),
      // Step 4: make a read function
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if we have data, get all the documents
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display the notes
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // get each indifidual note
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // get note from each document
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // display as a list tile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          // Step 5: make an update function
                          openNoteBox(docID: docID);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Step 6: make a delete function
                          firestoreService.deleteNote(docID);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          // if we don't have data, return nothing
          else {
            return Center(
              child: Text(
                "No notes available",
                style: TextStyle(fontSize: 20, color: Colors.redAccent),
              ),
            );
          }
        },
      ),
    );
  }
}
