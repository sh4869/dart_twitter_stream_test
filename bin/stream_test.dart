import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oauth/oauth.dart' as oauth;

Future<String> displaytweet(Stream<String> tweets) async {
  await for (var tweet in tweets) {
    try {
      var map = JSON.decode(tweet);
      if (!map.containsKey("delete")) {
        print(map["user"]["name"] + " " + map["text"]);
      }
    } catch (e) {
      print(e);
    }
  }
  return "";
}

main() async {
  var keyData = new File('./bin/key.json').readAsStringSync();
  var keyMap = JSON.decode(keyData);
  print("test");
  oauth.Tokens oauthToken = new oauth.Tokens(
      consumerId: keyMap["ci"],
      consumerKey: keyMap["ck"],
      userId: keyMap["ui"],
      userKey: keyMap["uk"]);
  var streamClient = new oauth.Client(oauthToken);
  Uri uri = Uri.parse("https://userstream.twitter.com/1.1/user.json");
  var request = new http.Request("GET", uri);
  var response = await streamClient.send(request);
  displaytweet(response.stream.toStringStream());
}
