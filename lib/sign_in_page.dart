import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'model/account.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;
  bool _isLoggedInFacebook = false;
  GoogleSignInAccount _userObj;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  Map _userObjFacebook = {};
  void saveUser(dynamic userData) async {
    final ggAuth = await userData.authentication;
    final GoogleAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: ggAuth.accessToken,
      idToken: ggAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(googleCredential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Hoàng Thắng")),
        body: Column(
          children: [
            _isLoggedIn
                ? Column(
                    children: [
                      Image.network(_userObj.photoUrl),
                      Text(_userObj.displayName),
                      Text(_userObj.email),
                      TextButton(
                          onPressed: () {
                            _googleSignIn.signOut().then((value) {
                              setState(() {
                                _isLoggedIn = false;
                              });
                            }).catchError((e) {});
                          },
                          child: Text("Logout"))
                    ],
                  )
                : Container(),
            Center(
              child: SignInButton(
                Buttons.Google,
                text: "Sign up with Google",
                // style: ElevatedButton.styleFrom(
                //   primary: _isLoggedIn ? Colors.grey : Colors.blue,
                //   // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                //   // textStyle:
                //   //     TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                // ),
                onPressed: () {
                  if (!_isLoggedIn) {
                    _googleSignIn.signIn().then((userData) {
                      setState(() {
                        _isLoggedIn = true;
                        _userObj = userData;
                        saveUser(_userObj);
                      });
                    }).catchError((e) {
                      print(e);
                    });
                  }
                },
              ),
            ),
            _isLoggedInFacebook
                ? Column(
                    children: [
                      Image.network(account.avatarUrl),
                      Text(account.fullName),
                      Text(account.phoneNumber),
                      TextButton(
                          onPressed: () {
                            FacebookAuth.instance.logOut().then((value) {
                              setState(() {
                                _isLoggedInFacebook = false;
                                _userObjFacebook = {};
                              });
                            });
                          },
                          child: Text("Logout"))
                    ],
                  )
                : Container(),
            Center(
              child: SignInButton(
                Buttons.Facebook,
                text: "Sign up with Facebook",
                onPressed: () async {
                  bool response = await logInWithFB();
                  if (response) {
                    print("Thanfh cong");
                    setState(() {
                      _isLoggedInFacebook = true;
                    });
                  } else {
                    print('Some thing wrong');
                  }
                },
              ),
            ),
          ],
        ));
  }

  Account account = new Account();
  // ignore: missing_return
  Future<bool> logInWithFB() async {
    await FacebookAuth.instance.logOut();
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        // permissions: ['email', 'public_profile', 'user_birthday'],
      ); // by the fault we request the email and the public profile
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance
            .getUserData(fields: "name,email,picture.width(200),birthday");
        account.fullName = userData['name'];
        if (userData['phone_number'] != null) {
          account.phoneNumber = userData['phoneNumber'];
        }
        if (userData['email'] != null) {
          account.phoneNumber = userData['email'];
        }
        account.avatarUrl = userData['picture']["data"]["url"];
        print('========================================================');
        print(userData.toString());
        return true;
      }
      print(result.status);
    } catch (e) {
      return false;
    }
  }
}
