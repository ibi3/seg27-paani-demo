import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:paani/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  var _loading = false;

  String _email, _password;

  bool _obscurePassword = true;

  void _showSnackBar(String text) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {
          scaffoldKey.currentState.removeCurrentSnackBar();
        },
      ),
    ));
  }

  Future<bool> _logUserIn() async {
    var result = await http.post('https://seg27-paani-backend.herokuapp.com/users/login',
        body: {'email_address': _email, 'password': _password});

    var credentials = json.decode(result.body);

    if (credentials['error'] == false) return true;
    else return false;

  }

  void _submit() async {
    final form = formKey.currentState;

    _loading = true;

    if (form.validate()) {
      form.save();

      if (await _logUserIn()) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (_) => false);
      } else {
        _showSnackBar("Incorrect email address or password");
      }
    }
    _loading = false;
  }

  Widget build(BuildContext context) {
    Widget paaniLogo = Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: Container(
        height: 200.0,
        width: 400.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo_transparentbg.png'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );

    Widget loginButton = ButtonTheme(
      padding: EdgeInsets.only(bottom: 1),
      minWidth: 300,
      child: RaisedButton(
        onPressed: _submit,
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );

    Widget loginForm = Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (text) {
                if (text.isEmpty) {
                  return 'Please enter your email address';
                }
                return null;
              },
              onSaved: (text) => _email = text,
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextFormField(
              validator: (text) {
                if (text.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onSaved: (text) => _password = text,
              cursorColor: Theme.of(context).primaryColor,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                      icon: _obscurePassword
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      onPressed: () => {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            })
                          })),
            ),
          ],
        ));

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Paani - Log in'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.info),
            color: Colors.white,
          ),
          FlatButton(
            onPressed: _submit,
            child: Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              paaniLogo,
              loginForm,
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: loginButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
