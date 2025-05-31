import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Notes/EditNotes.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../utils/utils.dart';
import 'CreateNotes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NotesScreen());
}

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final user = snapshot.data;
          if (user != null) {
            return MaterialApp(
              title: 'EduVantage',
              theme: ThemeData(
                colorScheme:
                ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    background: Colors.white,
                    error: Colors.red,
                    onTertiary: Colors.orange
                ),
              ),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Notes',
                    style: TextStyle(
                      fontFamily: AppFonts.alatsiRegular,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  backgroundColor: Color(0xFFe5f3fd),
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.black87),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: NotesSearch(userUID: user.uid),
                        );
                      },
                    ),
                  ],
                ),
                backgroundColor: Color(0xFFe5f3fd),
                body: NotesList(userUID: user.uid), // Pass the user's UID
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: CreateNotesScreen(),
                      withNavBar: false,
                    );
                  },
                  child: Icon(Icons.add, color: Colors.white),
                  backgroundColor: Colors.blue,
                  elevation: 1,
                ),
              ),
            );
          } else {
            return Center(child: Text('User not authenticated.'));
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class NotesList extends StatelessWidget {
  final String userUID;
  final String? searchTerm;

  NotesList({required this.userUID, this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Add your logic to refresh the data here, e.g., fetch the latest notes
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notes')
            .where('userUID', isEqualTo: userUID) // Filter by user's UID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notes found',
                style: TextStyle(
                  fontFamily: AppFonts.alatsiRegular,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            );
          }
          var notes = snapshot.data!.docs;

          // Filter notes by title or content if searchTerm is not null
          if (searchTerm != null && searchTerm!.isNotEmpty) {
            notes = notes.where((note) {
              final data = note.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final content = data['note'] ?? '';
              return title.toLowerCase().contains(searchTerm!.toLowerCase()) ||
                  content.toLowerCase().contains(searchTerm!.toLowerCase());
            }).toList();
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return NoteCard(note: notes[index]);
            },
          );
        },
      ),
    );
  }
}


class NoteCard extends StatelessWidget {
  final QueryDocumentSnapshot note;

  NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final data = note.data() as Map<String, dynamic>;
    final title = data['title'] ?? '';
    final content = data['note'] ?? '';
    final notificationDateTime = data['notificationDateTime'] != null
        ? (data['notificationDateTime'] as Timestamp).toDate()
        : null;


    // Parse the color from Firebase data
    final colorHexString = data['backgroundColor'] ?? '';
    final color = Color(int.parse(colorHexString, radix: 16));

    // Determine text color based on background color's luminance
    Color textColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    Color DTtextColor = color.computeLuminance() > 0.5 ? Colors.black38 : Colors.white54;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              elevation: 0,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              title: Text(
                "Confirm Deletion",
                style: TextStyle(
                  fontFamily: AppFonts.alatsiRegular,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Text(
                "Are you sure you want to delete this note?",
                style: TextStyle(fontFamily: AppFonts.alatsiRegular),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: AppFonts.alatsiRegular,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Delete the note from Firestore and dismiss the dialog
                    FirebaseFirestore.instance
                        .collection('Notes')
                        .doc(note.id)
                        .delete();
                    Navigator.of(context).pop(true);
                    Utils.toastMessage('Note ${title} deleted successfully');
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: AppFonts.alatsiRegular,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      background: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: Color(0xFFe5f3fd),
          child: Align(
            alignment: Alignment.center,
            child: Icon(CupertinoIcons.delete, color: Colors.red),
          ),
        ),
      ),
      child: Card(
        margin: EdgeInsets.all(8.0),
        color: color,
        elevation: 2,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: AppFonts.alatsiRegular
                ),
              ),
              SizedBox(height: 8),
              if (notificationDateTime != null) // Show notificationDateTime if available
                Text(
                  '${DateFormat('MMMM dd, yyyy h:mm a').format(notificationDateTime)}',
                  style: TextStyle(
                    color: DTtextColor,
                    fontSize: 12,
                    fontFamily: AppFonts.alatsiRegular
                  ),
                ),
            ],
          ),
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: EditNotesScreen(
                noteDocument: note,
              ),
              withNavBar: false,
            );
          },
          contentPadding: EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}

class NotesSearch extends SearchDelegate<String> {
  final String userUID;

  NotesSearch({required this.userUID});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: NotesList(
        userUID: userUID,
        searchTerm: query,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: SizedBox
          .shrink(), // You can return any widget here, adjust as needed
    );
  }
}