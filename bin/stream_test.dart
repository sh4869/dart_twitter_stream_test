import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oauth/oauth.dart' as oauth;

Future<String> displaytweet(Stream<String> tweets) async {
  RegExp exp = new RegExp("\{*\}");
  var file = new File("stream.txt");
  JsonDecoder decoder = new JsonDecoder();
  await for (var tweetSource in tweets) {
    var tweetText = LineSplitter.split(tweetSource);
    for (var tweet in tweetText) {
      if (exp.hasMatch(tweet)) {
        try {
          var tweetObj = decoder.convert(tweet);
          if (!tweetObj.containsKey("delete")) {
            print(tweetObj["text"] + " " + tweetObj["user"]["screen_name"]);
          }
        } catch (e) {
          print(e);
          file.writeAsStringSync(tweet + "\n",mode:FileMode.APPEND);
        }
      }
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
