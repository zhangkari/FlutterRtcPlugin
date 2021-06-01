import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rtc_plugin/rtc/rtc_sdk_type.dart';
import 'package:rtc_plugin_example/meeting_model.dart';

import 'debug/GenerateTestUserSig.dart';
import 'meeting_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeetingModel(),
      child: MaterialApp(
        title: 'Rtc Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Rtc Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _roomIdController = TextEditingController();
  final _uidController = TextEditingController();

  RTCSDKType _sdkType = RTCSDKType.Agora_RTC;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Agora_RTC"),
                leading: Radio(
                  value: RTCSDKType.Agora_RTC,
                  groupValue: _sdkType,
                  onChanged: (RTCSDKType value) {
                    setState(() {
                      _sdkType = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text("Tencent_RTC"),
                leading: Radio(
                  value: RTCSDKType.Tencent_RTC,
                  groupValue: _sdkType,
                  onChanged: (RTCSDKType value) {
                    setState(() {
                      _sdkType = value;
                    });
                  },
                ),
              ),
              Container(
                  child: TextField(
                    keyboardType:TextInputType.number,
                    controller: _uidController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'uid',
                    ),
                  )),
              Container(
                  child: TextField(
                    keyboardType:TextInputType.number,
                    controller: _roomIdController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Room Id',
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 提示浮层
  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  Future<void> onJoin() async {
    if( _uidController.text.isEmpty){
      showToast("请输入uid");
      return;
    }
    if(_roomIdController.text.isEmpty){
      showToast("请输入Room Id");
      return;
    }
    String uid = _uidController.text;

    String roomId=_roomIdController.text;
    String token="";
    if(_sdkType == RTCSDKType.Agora_RTC){
      token = await getHttp(roomId,int.parse(uid));
    }
    if(_sdkType == RTCSDKType.Tencent_RTC){
      token = await GenerateTestUserSig.genTestSig(uid);
    }
    if(token ==null || token.length<1){
      showToast("获取token失败，请重试");
      return;
    }

    String appId = getAppId(_sdkType);

    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingPage(appId,token,roomId,_sdkType,int.parse(uid)),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  Future<String> getHttp(String roomId,int uid) async {
    try {
      var response = await Dio().post('https://rtc-server.class100.com/agora/token',data: {
        "channel_name": roomId,
        "uid": uid
      });
      print(response);
      return response.data['data']['rtc_token'];
    } catch (e) {
      return "";
    }
  }

  String getAppId(RTCSDKType rtcsdkType){
    if(rtcsdkType == RTCSDKType.Tencent_RTC){
      return "1400522136";
    }else{
      return "dc727387e40a4dcd84f715ed66530f42";
    }
  }

}
