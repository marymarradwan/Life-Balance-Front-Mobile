import 'package:http/http.dart';

class network_client {
  static String Url ="https://lifecircle.admin.oxfordtraining.uk";
      //"https://api.cpoints.net";
  //"https://api.circulife.app";
  static String _baseUrl = Url;

  final Client _client;

  network_client(this._client);
}

