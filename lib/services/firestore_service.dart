import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:paw_pals/models/user_model.dart';
import 'package:paw_pals/models/post_model.dart';
import 'package:paw_pals/utils/app_log.dart';

/// A service class for interface with the [FirebaseFirestore] plugin.
class FirestoreService {
  FirestoreService._();
  /// Reference UID of the current auth-user
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Reference to the [FirebaseFirestore] instance
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference get _users => _db.collection('users');

  /// [DocumentReference] to the current user
  static DocumentReference<UserModel> get _userRef => _users.doc(_uid)
    .withConverter(
      fromFirestore: UserModel.fromFirestore,
      toFirestore: (UserModel user, _) => user.toFirestore());

  /// A broadcast stream that notifies listeners when the [UserModel] of the
  /// logged in user updates/changes.
  static Stream<UserModel?> get userModelStream => _userRef.snapshots()
      .map((snapshot) => snapshot.data()).asBroadcastStream();

  /// Fetches the data of the currently logged-in user and returns a [UserModel].
  /// A null value will be returned if an error occurred.
  static Future<UserModel?> getUser() async {
    if (_uid == null) {
      // Theres no User logged-in.
      Logger.log("No User is logged into Firebase Auth.", isError: true);
      return null;
    }
    // The call to Firestore
    return await _userRef
      .get()
      .then(
        (snapshot) => snapshot.data(),  // UserModel or null on err
        onError: (e) => Logger.log(e.toString(), isError: true)
      );
  }

  /// Creates a User document from a [UserModel] in the Firestore Database.
  /// [UserModel.uid] is required to create the doc in the database.
  /// This method should only be called on user sign-up.
  static Future<void> createUser(UserModel userModel) async {
    // Restrict creating/overwriting if not authorized.
    if (_uid == null || userModel.uid == null) {
      Logger.log("No User is logged into Firebase Auth.", isError: true);
      return;
    }
    if (userModel.uid != _uid) {
      Logger.log("User being created does not match the user logged in", isError: true);
      return;
    }
    // Set the timestamp to the moment the account was created.
    userModel.timestamp = DateTime.now().microsecondsSinceEpoch;
    await _userRef
      .set(userModel)
      .then((res) => Logger.log("Firestore doc created for ${userModel.email}"),
        onError: (e) => Logger.log(e.toString(), isError: true));
  }

  /// Updates a User from a [UserModel] in the Firestore Database. <br/>
  /// **Note:** only the following fields are considered editable. All other
  /// fields will **NOT** be overwritten by this method:
  /// * [UserModel.first]
  /// * [UserModel.last]
  /// * [UserModel.photoUrl]
  static Future<void> updateUser(UserModel userModel) async {
    // Restrict creating/overwriting if not authorized.
    if (_uid == null || userModel.uid == null) {
      Logger.log("No User is logged into Firebase Auth.", isError: true);
      return;
    }
    if (userModel.uid != _uid) {
      Logger.log("User being updated does not match the user logged in", isError: true);
      return;
    }
    
    await _userRef
      .update(userModel.toFirestoreUpdate())
      .then((res) => Logger.log("Firestore doc created for ${userModel.email}"),
        onError: (e) => Logger.log("Error creating Firestore doc for ${userModel.email}")
      );
  }

  static Future<PostModel?> getPostById(String postId) async {
    return null;
  }

  static Future<List<PostModel>?> getPostsByUser(UserModel userModel) async {
    return null;
  }

  static Future<PostModel?> getLikedPosts() async {
    return null;
  }

  static Future<Image?> getImageFromUrl(String url) async {
    return null;
  }

  /// Query all users and return if given username is unique.
  /// Returns null if error occurs.
  static Future<bool?> isUsernameUnique(String username) async {
    return await _users.where("username", isEqualTo: username).get().then(
      (res) => res.size < 1,
      onError: (e) {
        Logger.log(e.toString(), isError: true);
        return null;
      }
    );
  }
}