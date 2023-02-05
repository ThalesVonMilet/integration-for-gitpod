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
    "receiverName": "hello",
    "receiverUsername":"world",
    "senderName": "hello",
    "senderUsername":"world",
    "receiver":"new",
    "sender":"old"
  }

*/

Future<void> start(final req, final res) async {
  final client = Client();
  final database = Databases(client);

  if (req.variables['APPWRITE_FUNCTION_ENDPOINT'] == null ||
      req.variables['APPWRITE_FUNCTION_API_KEY'] == null) {
        print('Endpoint or function API Key are missing');
    res.send('Endpoint or function API Key are missing', status: 404);
    return;
  } else {
     print('before client');
    client
        .setEndpoint(req.variables['APPWRITE_FUNCTION_ENDPOINT'])
        .setProject(req.variables['APPWRITE_FUNCTION_PROJECT_ID'])
        .setKey(req.variables['APPWRITE_FUNCTION_API_KEY'])
        .setSelfSigned(status: true);

    Map<String, dynamic> payload;
    try {
      payload = json.decode(req.payload);
      print('Payload: ${req.payload}');
    } catch (error) {
      print('Payload: ${error}');
      res.send('AppwriteFunctionError : $error',status: 404);
      return;
    }

    await database.createDocument(
        databaseId: req.variables['APPWRITE_DATABASE_ID'],
        collectionId:  req.variables['APPWRITE_COLLECTION_ID'],
        documentId: 'unique()',
        data: {
          req.variables['APPWRITE_MAP_NAME_RECEIVER_NAME'] : payload[req.variables['APPWRITE_MAP_NAME_RECEIVER_NAME']],
          req.variables['APPWRITE_MAP_NAME_RECEIVER_USERNAME'] : payload[req.variables['APPWRITE_MAP_NAME_RECEIVER_USERNAME']], 
          req.variables['APPWRITE_MAP_NAME_RECEIVER'] : payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']],
          req.variables['APPWRITE_MAP_NAME_SENDER_NAME'] : payload[req.variables['APPWRITE_MAP_NAME_SENDER_NAME']],
          req.variables['APPWRITE_MAP_NAME_SENDER_USERNAME'] : payload[req.variables['APPWRITE_MAP_NAME_SENDER_USERNAME']],
          req.variables['APPWRITE_MAP_NAME_SENDER'] : payload[req.variables['APPWRITE_MAP_NAME_SENDER']],
        },
        permissions:[
          Permission.read(Role.user(payload[req.variables['APPWRITE_MAP_NAME_SENDER']])),
          Permission.write(Role.user(payload[req.variables['APPWRITE_MAP_NAME_SENDER']])),
          Permission.read(Role.user(payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']])),
          Permission.write(Role.user(payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']])),
        ]
    ).then((document) {
      print(document.data);
      res.json(document.data);
    },onError: (error){
      res.send('AppwriteFunctionError : $error',status: 404);
    });
  }
}

