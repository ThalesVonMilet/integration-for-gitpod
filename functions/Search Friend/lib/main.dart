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
   "input": "te",
    "sender":"63a3241db5c9fb7f83c8"
  }
*/

Future<void> start(final req, final res) async {
  final client = Client();

  final database = Databases(client);

  final String endpoint;
  final String functionApiKey;
  final String projectId;

  //final String errorCodePayload;
  //final String successCode;

  final String friendRequestDatabaseId;
  final String friendRequestCollectionId;

  final String usersDatabaseId;
  final String usersCollectionId;

  final String userMapNameName;
  final String userMapNameUsername;
  final String userMapNameUid;

  final String searchRequestMapNameSender;
  final String searchRequestMapNameSearchNameOrUsername;

  try {
    endpoint = req.variables['APPWRITE_FUNCTION_ENDPOINT'];
    functionApiKey = req.variables['APPWRITE_FUNCTION_API_KEY'];
    projectId = req.variables['APPWRITE_FUNCTION_PROJECT_ID'];

    //errorCodePayload = req.variables['APPWRITE_ERROR_CODE_PAYLOAD'];
    //successCode = req.variables['APPWRITE_FUNCTION_SUCCESS_CODE'];

    usersDatabaseId = req.variables['APPWRITE_USER_DATABASE_ID'];
    usersCollectionId = req.variables['APPWRITE_USER_COLLECTION_ID'];

    userMapNameName = req.variables['APPWRITE_MAP_NAME_USER_NAME'];
    userMapNameUsername = req.variables['APPWRITE_MAP_NAME_USER_USERNAME'];
    userMapNameUid = req.variables['APPWRITE_MAP_NAME_USER_UID'];

    searchRequestMapNameSender =
    req.variables['APPWRITE_MAP_NAME_SEARCH_REQUEST_SENDER'];
    searchRequestMapNameSearchNameOrUsername =
    req.variables['APPWRITE_MAP_NAME_SEARCH_REQUEST_NAME_OR_USERNAME'];

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

  final String input;
  final String sender;

  Map<String, dynamic> payload;
  try {
    payload = json.decode(req.payload);
    print('Payload: ${req.payload}');

    sender = payload[searchRequestMapNameSender];
    input = payload[searchRequestMapNameSearchNameOrUsername];
  } catch (error) {
    res.send('AppwriteFunctionError : $error');
    return;
  }

  Set<Map<String,dynamic>> results = {};

  if (input.isEmpty) {
    res.send('INPUT EMPTY');
    return;
  }

  await database.listDocuments(
      databaseId: usersDatabaseId,
      collectionId:usersCollectionId,
      queries: [
        Query.search('name', input),
        //Query.search('username', input)
      ]).then((documents) async {
    documents.documents.forEach((document) {
      print(document.data);
      if(document.$id != sender){
        results.add({
          userMapNameName : document.data[userMapNameName],
          userMapNameUsername : document.data[userMapNameUsername],
          userMapNameUid : document.$id
        });
      }
    });
    return;
  }, onError: (error) async {    print(error);
  });
  await database.listDocuments(
      databaseId: usersDatabaseId,
      collectionId:usersCollectionId,
      queries: [
        //Query.search('name', input),
        Query.search('username', input),
      ]).then((documents) async {
    print(documents.toMap);
    documents.documents.forEach((document) {
      print(document.data);
      if(document.$id != sender){
         
        Map<String,dynamic> friendSuggestion = {
          userMapNameName : document.data[userMapNameName],
          userMapNameUsername : document.data[userMapNameUsername],
          userMapNameUid : document.$id
        };

        bool contains = results.toString().contains(friendSuggestion.toString());
        if(contains == false){
          results.add(friendSuggestion);
        }
      
      }
    });
    return;
  }, onError: (error) async {    print(error);
  });


  //TODO 1 put people in vicinity on top


  try{
    res.json({'data': results.toList()});
    return;
  }catch(error){
    res.send(error.toString());
    return;
  }

}

class FriendSuggestion {
  late final String uid;
  late final String name;
  late final String username;
  late final String? profilePicture;

  FriendSuggestion({required this.uid, required this.name, required this.username, this.profilePicture});
}