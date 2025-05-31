import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_media/res/fonts.dart';

import '../../utils/utils.dart';

class RateAppDialog {
  static Future<void> showRateAppDialog(BuildContext context, String userUID) async  {
    final CollectionReference feedbackCollection =
    FirebaseFirestore.instance.collection('Feedback');

    int starRating = 0;
    List<String> favoriteFeatures = [];
    String suggestions = '';
    bool showStarError = false;
    bool showFeatureError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 0,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              scrollable: true,
              title: Center(child: Text('Rate EduVantage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('Enjoying our app? Please rate it:')),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 1; i <= 5; i++)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                starRating = i;
                                showStarError = false; // Reset star error state
                              });
                            },
                            icon: Icon(
                              i <= starRating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.yellow.shade800,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (showStarError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          'Please select a star rating',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Center(child: Text('Select your favorite features:')),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Class'),
                    value: favoriteFeatures.contains('Class'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Class');
                        } else {
                          favoriteFeatures.remove('Class');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Task'),
                    value: favoriteFeatures.contains('Task'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Task');
                        } else {
                          favoriteFeatures.remove('Task');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Notes'),
                    value: favoriteFeatures.contains('Notes'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Notes');
                        } else {
                          favoriteFeatures.remove('Notes');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Recorder'),
                    value: favoriteFeatures.contains('Recorder'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Recorder');
                        } else {
                          favoriteFeatures.remove('Recorder');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Flashcards'),
                    value: favoriteFeatures.contains('Flashcards'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Flashcards');
                        } else {
                          favoriteFeatures.remove('Flashcards');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Statistics'),
                    value: favoriteFeatures.contains('Statistics'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Statistics');
                        } else {
                          favoriteFeatures.remove('Statistics');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Scanner'),
                    value: favoriteFeatures.contains('Scanner'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Scanner');
                        } else {
                          favoriteFeatures.remove('Scanner');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Pomodoro'),
                    value: favoriteFeatures.contains('Pomodoro'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Pomodoro');
                        } else {
                          favoriteFeatures.remove('Pomodoro');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text('Contacts'),
                    value: favoriteFeatures.contains('Contacts'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          favoriteFeatures.add('Contacts');
                        } else {
                          favoriteFeatures.remove('Contacts');
                        }
                      });
                    },
                  ),
                  if (showFeatureError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          'Please select a favorite feature',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Container(
                    height: 5 * 24.0 + 43.0, // Height for 5 lines of text + additional padding for labelText
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5), // Adjust padding as needed
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Border color
                      borderRadius: BorderRadius.circular(8), // Border radius
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              'Suggestions',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22), // Style for labelText
                            ),
                          ),
                          SizedBox(height: 4.0), // Adjust spacing between labelText and TextFormField
                          TextFormField(
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Share your suggestions here (optional)',
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.zero, // Zero padding for TextFormField content
                              hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal, fontSize: 14), // Style for hintText
                            ),
                            onChanged: (value) {
                              suggestions = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      showStarError = starRating == 0;
                      showFeatureError = favoriteFeatures.isEmpty;
                    });

                    if (showStarError || showFeatureError) {
                      // Either star rating or feature selection is empty
                      return;
                    }

                    // If both star rating and feature selection are valid, save feedback
                    await saveFeedback(
                      feedbackCollection,
                      userUID,
                      starRating,
                      favoriteFeatures,
                      suggestions,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),
                ),
                )
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> saveFeedback(
      CollectionReference feedbackCollection,
      String userUID,
      int starRating,
      List<String> favoriteFeatures,
      String suggestions,
      ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Fetch user profile data
        Map<String, dynamic> userProfile = await getUserProfile(userUID);

        // Extract user details
        String userName = userProfile['userName'] as String;
        String userCourse = userProfile['course'] as String;
        String userDepartment = userProfile['department'] as String;
        String userEmail = userProfile['email'] as String;
        String userStudentNumber = userProfile['studentNumber'] as String;
        String userProfileImage = userProfile['profile'] as String;

        // Check if starRating and favoriteFeatures are selected
        if (starRating == 0 || favoriteFeatures.isEmpty) {
          print('Error: Please select star rating and favorite features');
          return; // Exit the method without saving feedback
        }

        await feedbackCollection.add({
          'userUID': userUID,
          'userName': userName,
          'userCourse': userCourse,
          'userDepartment': userDepartment,
          'userEmail': userEmail,
          'userStudentNumber': userStudentNumber,
          'userProfileImage' : userProfileImage,
          'starRating': starRating,
          'favoriteFeatures': favoriteFeatures,
          'suggestions': suggestions,
          'timestamp': Timestamp.now(),
        });
        print('Feedback saved to Firestore');
      } else {
        print('Error: Current user is null');
      }
    } catch (e) {
      print('Error saving feedback: $e');
    }
    Utils.toastMessage('Feedback submitted successfully');
  }



  static Future<Map<String, dynamic>> getUserProfile(String userUID) async {
    try {
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .ref('User')
          .child(userUID)
          .once();

      if (snapshot.snapshot.value != null && snapshot.snapshot.value is Map<dynamic, dynamic>) {
        return Map<String, dynamic>.from(snapshot.snapshot.value as Map<dynamic, dynamic>);
      } else {
        return {}; // Return an empty map if user data is not found or not in the expected format
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return {}; // Return an empty map in case of an error
    }
  }

}
