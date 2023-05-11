import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/io.dart';

import './login.dart';

var l = Logger();
signUp(context, user, nick, pass, cpass) async {
  String host = 'salty-lapis-lime.glitch.me';
  String auth = "chatappauthkey231r4";
  String url = 'ws://$host/login$user';
  bool isValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(user);

  if (isValid == true) {
    if (pass == cpass) {
      IOWebSocketChannel channel = IOWebSocketChannel.connect(url);
      try {
        await channel.ready;
      } catch (e) {
        l.e("Error on connecting to websocket: ${e.toString()}");
      }
      channel.sink.add('''{
        'auth':'$auth'
        ,'cmd':'signup'
        ,'email':'$user'
        ,'username':'$nick'
        ,'hash':'$cpass'
      }''');
      channel.stream.listen((event) async {
        event = event.replaceAll(RegExp("'"), '"');
        var res = json.decode(event);
        if (res["status"] == 'succes') {
          channel.sink.close();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        } else {
          channel.sink.close();
          l.d("Error signing signing up");
        }
      });
    } else {
      l.d("Password are not equal");
    }
  } else {
    l.d("email is false");
  }
}

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    late String user;
    late String name;
    late String pass;
    late String cpass;

    return Scaffold(
      appBar: AppBar(title: const Text("Signup.")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Mail...',
              ),
              onChanged: (e) => user = e,
            ),
          ),
          Center(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Username..',
              ),
              onChanged: (e) => name = e,
            ),
          ),
          Center(
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              onChanged: (e) => pass = e,
            ),
          ),
          Center(
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Confirm password',
              ),
              onChanged: (e) => cpass = e,
            ),
          ),
          Center(
            child: MaterialButton(
              child: const Text("Sign up"),
              onPressed: () {
                signUp(context, user, name, pass, cpass);
              },
            ),
          ),
        ],
      ),
    );
  }
}
