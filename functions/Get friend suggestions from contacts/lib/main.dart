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
    "sender":"63a3241db5c9fb7f83c8"

  }
*/

Future<void> start(final req, final res) async {
  final client = Client();

  final database = Databases(client);

  final String endpoint;
  final String functionApiKey;
  final String projectId;


  final String usersDatabaseId;
  final String usersCollectionId;
  final String contactsCollectionId;


  final String payloadSender;
  final String payloadInput;

  try {
    endpoint = req.variables['APPWRITE_FUNCTION_ENDPOINT'];
    functionApiKey = req.variables['APPWRITE_FUNCTION_API_KEY'];
    projectId = req.variables['APPWRITE_FUNCTION_PROJECT_ID'];

    usersDatabaseId = req.variables['APPWRITE_USER_DATABASE_ID'];
    usersCollectionId = req.variables['APPWRITE_USER_COLLECTION_ID'];
    contactsCollectionId = req.variables['APPWRITE_CONTACTS_COLLECTION_ID'];


    payloadSender =
    req.variables['APPWRITE_PAYLOAD_NAME_SENDER'];
    print(payloadSender);
    payloadInput =
    req.variables['APPWRITE_PAYLOAD_NAME_INPUT'];
  } catch (error) {
    res.send('Variables: $error', status: 100);
    print(error);
    return;
  }

  client
      .setEndpoint(endpoint)
      .setProject(projectId)
      .setKey(functionApiKey)
      .setSelfSigned(status: true);

  //final String input;
  String sender;

  Map<String, dynamic> payload;
  try {
    payload = json.decode(req.payload);
    print('Payload: ${req.payload}');
    print('Payload: ${payload}');

    sender = payload[payloadSender].toString();
    print(sender);
    //input = payload[payloadInput];
  } catch (error) {
    res.send('AppwriteFunctionPayloadError : $error');
    return;
  }

 Set<Map<String, dynamic>> results = {};

  Set<String> contacts = {};
    try {
    // get contacts of user
  await database
      .getDocument(
      databaseId: usersDatabaseId,
      collectionId: contactsCollectionId,
      documentId: sender)
      .then((document) async {
        print(document.data);
    List<String> contactsTest = List<String>.from(document.data['contacts']);
    print(contactsTest);
    await database
        .updateDocument(
        databaseId: usersDatabaseId,
        collectionId: contactsCollectionId,
        documentId: sender,
        data: {'contacts' : contacts}
    );
    return;
  }, onError: (error) async {
    print(error);
  });
  } catch (error) {
    res.send('AppwriteFunctionGetContactsError : $error');
    return;
  }
  

  /* Set<String> friends = {};
  // get friends of user
  await database
      .getDocument(
      databaseId: usersDatabaseId,
      collectionId: usersCollectionId,
      documentId: sender)
      .then((document) async {
    friends = Set<String>.from(document.data['friends']);
    return;
  }, onError: (error) async {
    print(error);
  });

  // add all conditions to query
  List<String> queries = [
    Query.notEqual('\$id', sender),
  ];

  friends.forEach((friendId) {
    queries.add(Query.notEqual('\$id', friendId));
  });

  contacts.forEach((phoneNumber) {
    queries.add(Query.search('contacts', phoneNumber));
  });

  print('Queries : $queries');

  List<String> count = [];
  // receive the document ids of the query
  await database
      .listDocuments(
      databaseId: usersDatabaseId,
      collectionId: usersCollectionId,
      queries: queries)
      .then((documents) async {
    documents.documents.forEach((document) {
      count.add(document.$id);
    });
    return;
  }, onError: (error) async {
    print(error);
  });

  print('Queried contacts result: $count');

  /*List<Map<String, int>> uidCompatibility = [];
  print(count);
  Set.of(count).toList().forEach((uid) {
    int compatibility = List.of(count).where((item) => item == uid).length;
    uidCompatibility.add({uid: compatibility});
  });
  print(uidCompatibility);*/

  // get all these users and take the info for the friend suggestion
  /*count.forEach((element) async {
    await database
        .getDocument(
        databaseId: usersDatabaseId,
        collectionId: usersCollectionId,
        documentId: element)
        .then((document) async {
      document.data;
      Map<String, dynamic> friendSuggestion = {
        'uid': document.$id,
        'name': document.data['name'],
        'username': document.data['username'],
      };
      results.add(friendSuggestion);
      return;
    }, onError: (error) async {
      print(error);
    });
  });*/

  try {
    res.json({'data': results.toList()});
    return;
  } catch (error) {
    res.send(error.toString());
    return;
  }
  */
}
