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
   name: "hello",
    username:"world",
    receiver:"new",
    sender:"old"
  }

  {
   "name": "hello",
    "username":"world",
    "receiver":"new",
    "sender":"old"
  }
*/

Future<void> start(final req, final res) async {
  final client = Client();

  // Uncomment the services you need, delete the ones you don't
  // final account = Account(client);
  // final avatars = Avatars(client);
  final database = Databases(client);
  // final functions = Functions(client);
  // final health = Health(client);
  // final locale = Locale(client);
  // final storage = Storage(client);
  // final teams = Teams(client);
  // final users = Users(client);

  if (req.variables['APPWRITE_FUNCTION_ENDPOINT'] == null ||
      req.variables['APPWRITE_FUNCTION_API_KEY'] == null) {
    res.send('Endpoint or function API Key are missing', status: 404);
    return;
  } else {
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
      res.send('AppwriteFunctionError : $error',status: 404);
      return;
    }

    await database.createDocument(
        databaseId: req.variables['APPWRITE_DATABASE_ID'],
        collectionId:  req.variables['APPWRITE_COLLECTION_ID'],
        documentId: 'unique()',
        data: {
          req.variables['APPWRITE_MAP_NAME_NAME'] : payload[req.variables['APPWRITE_MAP_NAME_NAME']],
          req.variables['APPWRITE_MAP_NAME_USERNAME'] : payload[req.variables['APPWRITE_MAP_NAME_USERNAME']],
          req.variables['APPWRITE_MAP_NAME_SENDER'] : payload[req.variables['APPWRITE_MAP_NAME_SENDER']],
          req.variables['APPWRITE_MAP_NAME_RECEIVER'] : payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']]
        },
        permissions:[
          Permission.read(Role.user(payload[req.variables['APPWRITE_MAP_NAME_SENDER']])),
          Permission.write(Role.user(payload[req.variables['APPWRITE_MAP_NAME_SENDER']])),
          //Permission.delete(Role.user(payload[req.variables['APPWRITE_MAP_NAME_SENDER']])),
          Permission.read(Role.user(payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']])),
          Permission.write(Role.user(payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']])),
          //Permission.delete(Role.user(payload[req.variables['APPWRITE_MAP_NAME_RECEIVER']])),
        ]
    ).then((document) {
      res.json(document.data);
    },onError: (error){
      res.send('AppwriteFunctionError : $error',status: 404);
    });
  }

}

