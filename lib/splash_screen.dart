import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? version;

  _startDelay() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
    Timer(const Duration(seconds: 1), _checkVersion);
  }
  var remoteConfig = FirebaseRemoteConfig.instance;
  _checkVersion() async {
    
    await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ));
    await remoteConfig.setDefaults(
        {
          "Version":version,
        });
    await remoteConfig.fetch();
    await remoteConfig.fetchAndActivate();
    var requiredBuildNumber =remoteConfig.getString("Version");
    print(version);
    print(requiredBuildNumber);
    if(version!.compareTo(requiredBuildNumber) == -1)
      {
        showAndroidUpdateDialog();
      }
    else
      {
        Navigator.push(context,MaterialPageRoute(builder: (context)=>MyHomePage(title: 'test')));
      }
  }
  Future<dynamic> showAndroidUpdateDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title:Text('update'),
            content: Text('update'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  final Uri url = Uri.parse(remoteConfig.getString('url'));
                  _launchUrl(url);
                },
                child:Text('update'),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url,mode: LaunchMode.externalApplication,)) {
      throw Exception('Could not launch $url');
    }
  }
  @override
  void initState()
  {
    super.initState();
    _startDelay();
  }
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
