import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:oxo/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

login(context, user, pass) async {
  var l = Logger();
  String host = 'salty-lapis-lime.glitch.me';
  String auth = "chatappauthkey231r4";
  String url = 'ws://$host/login$user';

  if (user.isNotEmpty && pass.isNotEmpty) {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(url);
    try {
      await channel.ready;
    } catch (e) {
      l.e("Error on connecting to websocket: ${e.toString()}");
    }

    channel.sink.add('''{
      'auth':'$auth'
      ,'cmd':'login'
      ,'email':'$user'
      ,'hash':'$pass'
    }''');
    channel.stream.listen((event) async {
      event = event.replaceAll(RegExp("'"), '"');
      var res = json.decode(event);
      if (res["status"] == 'success') {
        channel.sink.close();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loggedin', true);
        prefs.setString('mail', user);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        channel.sink.close();
        l.e("Error login");
      }
    });
  } else {
    l.d("Password are not equal");
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
