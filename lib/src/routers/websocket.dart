import 'package:alfred/alfred.dart';
// ignore: implementation_imports
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:apollocode_dart_utilities/src/models/ws_user.dart';
import 'package:apollocode_dart_utilities/src/services/websocket.dart';

class WebsocketRouter {
  WebsocketRouter(NestedRoute app,
      {bool useAuth = true,
      Future<bool> Function(String token)? authValidationFunction,
      Future<String> Function(String token)? getIdentifier}) {
    app.get('/', (req, res) {
      return WebSocketSession(
          onOpen: (ws) async {
            String? id;

            if (useAuth) {
              var authorization =
                  req.uri.queryParameters['authorization'] ?? "";
              if (authValidationFunction == null || getIdentifier == null) {
                throw Error();
              }

              var tokenIsValid = await authValidationFunction(authorization);

              if (!tokenIsValid) {
                print("A websocket connection failed: authentication failed.");
                ws.close(493, "Authentication failed.");
                return;
              }

              id = await getIdentifier(authorization);
            }

            WebsocketService.users.add(WsUser(ws, id ?? ""));
            print("USER JOINED");

            WebsocketService.users
                .where((user) => user.ws != ws)
                .forEach((user) => user.ws.send('A new user joined the chat.'));
          },
          onClose: (ws) {
            WebsocketService.users.removeWhere((element) => element.ws == ws);
            print("USER LEFT");
            for (var user in WebsocketService.users) {
              user.ws.send('A user has left.');
            }
          },
          onMessage: WebsocketService.onMessage);
    });
  }
}
