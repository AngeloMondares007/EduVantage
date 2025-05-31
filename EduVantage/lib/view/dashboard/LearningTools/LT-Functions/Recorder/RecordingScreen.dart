import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Recorder/AddRecordScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RecorderScreen());
}

class RecorderScreen extends StatefulWidget {
  @override
  _RecorderScreenState createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final GoogleSignIn _googleSignIn =
  GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.readonly']);
  var duration = 0;
  late Future<List<Map<String, dynamic>>> _fetchFilesFuture;
  List<Map<String, dynamic>> _fileList = [];

  @override
  void initState() {
    super.initState();
    _fetchFilesFuture = _fetchDriveFiles();
  }

  Future<List<Map<String, dynamic>>> _fetchDriveFiles() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      final googleSignInAuthentication =
      await googleSignInAccount?.authentication;

      if (googleSignInAuthentication != null) {
        final accessToken = auth.AccessToken(
          'Bearer',
          googleSignInAuthentication.accessToken!,
          DateTime.now().add(Duration(hours: 1)).toUtc(),
        );

        final credentials = auth.AccessCredentials(
          accessToken,
          null,
          [],
          idToken: googleSignInAuthentication.idToken,
        );

        final authClient = auth.authenticatedClient(
          http.Client(),
          credentials,
        );

        final driveApi = drive.DriveApi(authClient);

        final files = await driveApi.files.list(
          $fields: 'files(id, name, webViewLink, webContentLink, size, fileExtension)',
        );

        return Future.wait(files.files?.where((file) {
          return file.name?.toLowerCase().endsWith('.aac') ?? false;
        }).map((file) async {
          int bitrate = 256053;
          double fileSize = file.size != null ? double.parse(file.size.toString()) : 0;
          double durationInSeconds = (fileSize * 8) / bitrate;
          int minutes = durationInSeconds ~/ 60;
          int seconds = durationInSeconds.round() % 60;
          log(fileSize.toString());
          return {
            'id': file.id,
            'title': file.name,
            'duration': '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            'color': Colors.white,
            'url': file.webViewLink,
          };
        }).toList() ?? []);
      }
    } catch (e) {
      print('Error fetching files: $e');
    }
    return [];
  }

  Future<void> _refreshData() async {
    setState(() {
      _fetchFilesFuture = _fetchDriveFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            'Recordings',
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
          actions: [
            // IconButton(
            //   icon: Icon(Icons.search),
            //   onPressed: () {
            //     showSearch(
            //         context: context,
            //         delegate: _SearchDelegate(fileList: _fileList));
            //   },
            // ),
          ],
        ),
        backgroundColor: Color(0xFFe5f3fd),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchFilesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No recordings found', style: TextStyle(fontFamily: AppFonts.alatsiRegular),));
              } else {
                _fileList = snapshot.data ?? [];
                return RecordList(fileList: _fileList);
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: AddRecordScreen(),
              withNavBar: false,
            );
          },
          child: Icon(Icons.keyboard_voice_rounded, color: Colors.white),
          elevation: 1,
          backgroundColor: CupertinoColors.destructiveRed,
        ),
      ),
    );
  }
}

class RecordList extends StatefulWidget {
  final List<Map<String, dynamic>> fileList;
  RecordList({required this.fileList});
  @override
  _RecordList createState() => _RecordList(fileList: fileList);
}

class _RecordList extends State<RecordList> {
  final List<Map<String, dynamic>> fileList;
  _RecordList({required this.fileList});
  late Future<List<Map<String, dynamic>>> updatedFileList;
  final GoogleSignIn _googleSignIn =
  GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.readonly']);


  @override
  void initState() {
    super.initState();
    updatedFileList = _fetchDriveFiles();
  }

  Future<List<Map<String, dynamic>>> _fetchDriveFiles() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      final googleSignInAuthentication =
      await googleSignInAccount?.authentication;

      if (googleSignInAuthentication != null) {
        final accessToken = auth.AccessToken(
          'Bearer',
          googleSignInAuthentication.accessToken!,
          DateTime.now().add(Duration(hours: 1)).toUtc(),
        );

        final credentials = auth.AccessCredentials(
          accessToken,
          null,
          [],
          idToken: googleSignInAuthentication.idToken,
        );

        final authClient = auth.authenticatedClient(
          http.Client(),
          credentials,
        );

        final driveApi = drive.DriveApi(authClient);

        final files = await driveApi.files.list(
          $fields: 'files(id, name, webViewLink, webContentLink, size, fileExtension)',
        );

        return Future.wait(files.files?.where((file) {
          return file.name?.toLowerCase().endsWith('.aac') ?? false;
        }).map((file) async {
          int bitrate = 256053;
          double fileSize = file.size != null ? double.parse(file.size.toString()) : 0;
          double durationInSeconds = (fileSize * 8) / bitrate;
          int minutes = durationInSeconds ~/ 60;
          int seconds = durationInSeconds.round() % 60;
          log(fileSize.toString());
          return {
            'id': file.id,
            'title': file.name,
            'duration': '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            'color': Colors.blue,
            'url': file.webViewLink,
          };
        }).toList() ?? []);
      }
    } catch (e) {
      print('Error fetching files: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Add your logic to refresh the data here, e.g., fetch the latest voice records
      },
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: fileList.length,
        itemBuilder: (BuildContext context, int index) {
          final file = fileList[index];
          return Container(
            width: 200,
            margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: AudioPanel(
              fileData: file,
              updateFileList: () {
                setState(() {
                  updatedFileList = _fetchDriveFiles();
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class AudioPanel extends StatelessWidget {
  final Map<String, dynamic> fileData;
  final Function updateFileList;

  AudioPanel({
    required this.fileData,
    required this.updateFileList,
  });

  void _editFile(BuildContext context) {
    String fileNameWithoutExtension = fileData['title']!.replaceAll('.aac', '');
    TextEditingController _textEditingController = TextEditingController(text: fileNameWithoutExtension);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit File Name',
            style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.bold),
          ),
          content: TextFormField(
            style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.normal),
            cursorColor: Colors.black87,
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Enter new file name',
              hintStyle: TextStyle(fontWeight: FontWeight.normal, fontFamily: AppFonts.alatsiRegular),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black87, width: 2),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newFileName = _textEditingController.text.trim();
                if (newFileName.isNotEmpty) {
                  Navigator.of(context).pop();
                  Utils.toastMessage('File name updated: $newFileName');
                  newFileName += '.aac'; // Add the extension back when saving
                  fileData['title'] = newFileName;
                  updateFileList(); // Call the updateFileList function to trigger the update

                  // Call the function to rename the file in Google Drive
                  await _renameFile(fileData['id'], newFileName);
                } else {
                  Utils.toastMessage('Error renaming the file');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.black87, fontFamily: AppFonts.alatsiRegular),
              ),
            ),
          ],
        );
      },
    );
  }



  Future<void> _renameFile(String? fileId, String newName) async {
    if (fileId == null) {
      return;
    }

    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
          scopes: ['https://www.googleapis.com/auth/drive.file']);

      final googleSignInAccount = await _googleSignIn.signIn();
      final googleSignInAuthentication = await googleSignInAccount?.authentication;

      if (googleSignInAuthentication != null) {
        final accessToken = auth.AccessToken(
            'Bearer',
            googleSignInAuthentication.accessToken!,
            DateTime.now().add(Duration(hours: 1)).toUtc());

        final credentials = auth.AccessCredentials(
          accessToken,
          null,
          [],
          idToken: googleSignInAuthentication.idToken,
        );

        final authClient = auth.authenticatedClient(
          http.Client(),
          credentials,
        );

        final driveApi = drive.DriveApi(authClient);

        await driveApi.files.update(drive.File()..name = newName, fileId).then((value) => {
          updateFileList()
        });
      }
    } catch (e) {
      print('Error renaming file: $e');
    }
  }

  void _deleteFile(BuildContext context, String? fileId) async {
    // Implement your delete file logic here
    if (fileId == null) {
      return;
    }

    try {
      final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.file']);

      final googleSignInAccount = await _googleSignIn.signIn();
      final googleSignInAuthentication =
      await googleSignInAccount?.authentication;

      if (googleSignInAuthentication != null) {
        final accessToken = auth.AccessToken(
            'Bearer',
            googleSignInAuthentication.accessToken!,
            DateTime.now().add(Duration(hours: 1)).toUtc());

        final credentials = auth.AccessCredentials(
          accessToken,
          null,
          [],
          idToken: googleSignInAuthentication.idToken,
        );

        final authClient = auth.authenticatedClient(
          http.Client(),
          credentials,
        );

        final driveApi = drive.DriveApi(authClient);

        await driveApi.files.delete(fileId).then((value) => updateFileList());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('File deleted successfully'),
        ));
        // Call the updateFileList function to trigger the update
      }
    } catch (e) {
      print('Error deleting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting file'),
      ));
    }
  }

  // void _playAudio(BuildContext context) {
  //   // Navigate to AudioPlayerScreen and pass the necessary data
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AudioPlayerScreen(
  //         audioUrl: fileData['audioUrl'],
  //         title: fileData['title'],
  //       ),
  //     ),
  //   );
  // }

  void openAudioFile(String id, String link) async {
    if (!await launchUrl(Uri.parse(link))) {
      throw Exception('Could not launch $Uri.parse(link)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 0,
      color: fileData['color'] ?? Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              fileData['title'] != null ? fileData['title'].substring(0, fileData['title'].indexOf('.aac') > 0 ? fileData['title'].indexOf('.aac') : fileData['title'].length): '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              'Duration: ${fileData['duration'] ?? ''}',
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            onTap: () {
              openAudioFile(fileData['id'], fileData['url']);
            },

            trailing: PopupMenuButton(
              color: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),

              iconColor: Colors.black,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular),),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular),),
                ),
              ],
              onSelected: (String value) {
                if (value == 'edit') {
                  _editFile(context);
                } else if (value == 'delete') {
                  _deleteFile(context, fileData['id']);
                }
              },
            ),

          ),
        ],
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> fileList;

  _SearchDelegate({required this.fileList});

  List<Map<String, dynamic>> _filteredFiles = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
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
    _filterFiles(query);

    return ListView.builder(
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        final file = _filteredFiles[index];
        return ListTile(
          title: Text(file['title'] ?? ''),
          subtitle: Text('Duration: ${file['duration'] ?? ''}'),
          onTap: () {
            log(file['url']);
            // Implement what happens when a search result is tapped
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filterFiles(query);

    return Container(
      color: Color(0xFFe5f3fd),
      child: ListView.builder(
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          final file = _filteredFiles[index];
          return ListTile(
            title: Text(file['title'] ?? ''),
            subtitle: Text('Duration: ${file['duration'] ?? ''}'),
            onTap: () {
              // Implement what happens when a suggestion is tapped
            },
          );
        },
      ),
    );
  }

  void _filterFiles(String query) {
    _filteredFiles = fileList.where((file) {
      final title = file['title'].toLowerCase();
      final queryLower = query.toLowerCase();

      return title.contains(queryLower) && title.contains('.aac');
    }).toList();
  }
}
