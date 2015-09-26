import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oauth/oauth.dart' as oauth;

const int _LF = 10;
const int _CR = 13;

Iterable<String> splitOnlyCRLF(String lines, [int start = 0, int end]) sync* {
  end = RangeError.checkValidRange(start, end, lines.length);
  int sliceStart = start;
  int char = 0;
  for (int i = start; i < end; i++) {
    int previousChar = char;
    char = lines.codeUnitAt(i);
    if (char != _LF) continue;
    if (previousChar != _CR) {
      continue;
    }
    yield lines.substring(sliceStart, i);
    sliceStart = i + 1;
  }
  if (sliceStart < end) {
    yield lines.substring(sliceStart, end);
  }
}

Future<String> displaytweet(Stream<String> tweetData) async {
  JsonDecoder decoder = new JsonDecoder();
  String BrokenTweet = "";
  await for (var tweetSource in tweetData) {
    var tweetText = splitOnlyCRLF(tweetSource);
    for (var tweet in tweetText) {
      try {
        tweet = BrokenTweet + tweet;
        tweet = tweet.replaceAll(new RegExp("(\r|\n)"), "");
        if (tweet.startsWith("{") && tweet.endsWith("}")) {
          var tweetObj = decoder.convert(tweet);
          if (tweetObj.containsKey("created_at")) {
            print(tweetObj["text"] + " " + tweetObj["user"]["screen_name"]);
          }
          BrokenTweet = "";
        } else {
          BrokenTweet = tweet;
        }
      } catch (e) {
        print(e.toString());
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
