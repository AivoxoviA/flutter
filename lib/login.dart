import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxo/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

login(context, _mail, _pwd) async {
  String host = 'salty-lapis-lime.glitch.me';
  String auth = "chatappauthkey231r4";
  String url = 'ws://$host/login$_mail';

  if (_mail.isNotEmpty && _pwd.isNotEmpty) {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(url);
    try {
      await channel.ready;
    } catch (e) {
      print("Error on connecting to websocket: " + e.toString());
    }

    String signUpData =
        "{'auth':'$auth','cmd':'login','email':'$_mail','hash':'$_pwd'}";
    channel.sink.add(signUpData);
    channel.stream.listen((event) async {
      event = event.replaceAll(RegExp("'"), '"');
      var loginData = json.decode(event);
      if (loginData["status"] == 'success') {
        channel.sink.close();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loggedin', true);
        prefs.setString('mail', _mail);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        channel.sink.close();
        print("Error login");
      }
    });
  } else {
    print("Password are not equal");
  }
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    late String _mail;
    late String _pwd;

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Mail or password..',
              ),
              onChanged: (e) => _mail = e,
            ),
          ),
          Center(
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Password..',
              ),
              onChanged: (e) => _pwd = e,
            ),
          ),
          Center(
            child: MaterialButton(
              child: Text("Login"),
              onPressed: () {
                login(context, _mail, _pwd);
              },
            ),
          ),
        ],
      ),
    );
  }
}
