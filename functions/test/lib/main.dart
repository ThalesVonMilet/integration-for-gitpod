import 'package:dart_appwrite/dart_appwrite.dart';
import 'dart:async';
import 'dart:convert';

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status: status)' - function to return text response. Status code defaults to 200
    'json(obj, status: status)' - function to return JSON response. Status code defaults to 200

  If an error is thrown, a response with code 500 will be returned.

  test payload:

  {
   "name": "lenny",
    "username":"lenny_03",
    "receiver":"63a3a4d7549955dc7fa7",
    "sender":"63a3241db5c9fb7f83c8"
  }
*/

Future<void> start(final req, final res) async {
  final client = Client();

  final database = Databases(client);

  final String endpoint;
  final String functionApiKey;
  final String projectId;

  final String errorCodePayload;
  final String successCode;

  final String friendRequestDatabaseId;
  final String friendRequestCollectionId;

  final String usersDatabaseId;
  final String usersCollectionId;

  final String userMapNameFriends;

  final String friendRequestMapNameSender;
  final String friendRequestMapNameReceiver;

  try {
    endpoint = req.variables['APPWRITE_FUNCTION_ENDPOINT'];
    functionApiKey = req.variables['APPWRITE_FUNCTION_API_KEY'];
    projectId = req.variables['APPWRITE_FUNCTION_PROJECT_ID'];

    errorCodePayload = req.variables['APPWRITE_ERROR_CODE_PAYLOAD'];
    successCode = req.variables['APPWRITE_FUNCTION_SUCCESS_CODE'];

    friendRequestDatabaseId =
        req.variables['APPWRITE_FRIEND_REQUEST_DATABASE_ID'];
    friendRequestCollectionId =
        req.variables['APPWRITE_FRIEND_REQUEST_COLLECTION_ID'];

    usersDatabaseId = req.variables['APPWRITE_USER_REQUEST_DATABASE_ID'];
    usersCollectionId = req.variables['APPWRITE_USER_COLLECTION_ID'];

    userMapNameFriends = req.variables['APPWRITE_MAP_NAME_USER_FRIENDS'];

    friendRequestMapNameSender =
        req.variables['APPWRITE_MAP_NAME_FRIEND_REQUEST_SENDER'];
    friendRequestMapNameReceiver =
        req.variables['APPWRITE_MAP_NAME_FRIEND_REQUEST_RECEIVER'];
  } catch (error) {
    res.send('Variables: $error', status: 100);
    return;
  }

print('variables ok');

  client
      .setEndpoint(endpoint)
      .setProject(projectId)
      .setKey(functionApiKey)
      .setSelfSigned(status: true);

  print('client ok');

  final String sender;
  final String receiver;

  Map<String, dynamic> payload;
  try {
    payload = json.decode(req.payload);
    print('Payload: ${req.payload}');

    sender = payload[friendRequestMapNameSender];
    receiver = payload[friendRequestMapNameReceiver];
  } catch (error) {
    res.send('AppwriteFunctionError : $error');
    return;
  }

  print('payload ok');

  await database.listDocuments(
      databaseId: friendRequestDatabaseId,
      collectionId: friendRequestCollectionId,
      queries: [
        Query.equal(friendRequestMapNameSender, sender),
        Query.equal(friendRequestMapNameReceiver, receiver)
      ]).then((documents) {
        documents.documents.forEach((document) async {
          await database.deleteDocument(
              databaseId:  document.$databaseId,
              collectionId: document.$collectionId,
              documentId: document.$id);
        });
  }, onError: (error) {
    res.send('AppwriteFunctionError : $error');
    print(error);
    return;
  });

   print('delete ok');

  await database
      .getDocument(
          databaseId: usersDatabaseId,
          collectionId: usersCollectionId,
          documentId: sender)
      .then((document) async {
    Set<String> friends = Set<String>.from(document.data[userMapNameFriends].toSet() ?? [].toSet());
    print('friends sender ${document.data[userMapNameFriends]}');
    print('friends sender new list ${friends}');
    friends.remove('');    
    friends.add(receiver);
    print('friends sender added list ${friends}');

    List<String> permissions = List<String>.from(document.$permissions);
    permissions.add(Permission.read(Role.user(receiver)));

    await database
        .updateDocument(
            databaseId:  document.$databaseId,
            collectionId: document.$collectionId,
            documentId: document.$id,
            data: {
              userMapNameFriends:  friends.toList(),
            },
            permissions: permissions)
        .then((document) async {}, onError: (error) async {
      res.send('AppwriteFunctionError : $error');
          return;
    });
  }, onError: (error) async {
    res.send('AppwriteFunctionError : $error');
        return;
  });

    print('sender ok');

  await database
      .getDocument(
    databaseId: usersDatabaseId,
    collectionId: usersCollectionId,
    documentId: receiver,
  )
      .then((document) async {
      Set<String> friends = Set<String>.from(document.data[userMapNameFriends].toSet() ?? [].toSet());
    print('friends sender ${document.data[userMapNameFriends]}');
    print('friends sender new list ${friends}');
    friends.remove('');    
    friends.add(sender);
    print('friends sender added list ${friends}');


    List<String> permissions = List<String>.from(document.$permissions);
    permissions.add(Permission.read(Role.user(sender)));

    await database
        .updateDocument(
          databaseId:  document.$databaseId,
          collectionId: document.$collectionId,
          documentId: document.$id,
            data: {
              userMapNameFriends: friends.toList(),
            },
            permissions: permissions)
        .then((documents) async {
            res.send('AppwriteFunction: added friend', status: 100);
        }, onError: (error) async {
      res.send('AppwriteFunctionError : $error');
          return;
    });
  }, onError: (error) async {
    res.send('AppwriteFunctionError : $error');
        return;
  });

    print('receiver ok');

 
}
