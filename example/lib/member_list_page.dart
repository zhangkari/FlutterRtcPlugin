import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rtc_plugin/rtc/rtc_controller.dart';
import 'package:rtc_plugin_example/meeting_member.dart';

import 'meeting_model.dart';

/// 成员列表页面
class MemberListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MemberListPageState();
}

class MemberListPageState extends State<MemberListPage> {
  RTCController _rtcController;
  var meetModel;
  var userInfo;
  List<MeetingMember> userList;
  Map<int,bool> muteMicMap = {};
  Map<int,bool> muteVideoMap = {};

  @override
  initState() {
    super.initState();
    initRoom();
    meetModel = context.read<MeetingModel>();
  }

  initRoom() async {
    _rtcController = RTCController();
  }

  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  dispose() {
    super.dispose();
    muteMicMap = {};
    muteVideoMap = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成员列表'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Container(
        color: Color.fromRGBO(14, 25, 44, 1),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Consumer<MeetingModel>(
                builder: (context, meetModel, child) {
                  userList = meetModel.userList;
                  return ListView(
                    children: userList
                        .map<Widget>((item) => Container(
                              key: ValueKey(item.uid.toString()),
                              height: 50,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(item.uid.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Offstage(
                                      offstage:
                                          item.uid == meetModel.uid,
                                      child: IconButton(
                                          icon: Icon(
                                            muteVideoMap[item.uid]==null? Icons.videocam: Icons.videocam_off,
                                            color: Colors.white,
                                            size: 36.0,
                                          ),
                                          onPressed: () {
                                            if(muteVideoMap[item.uid] == null){
                                              muteVideoMap[item.uid] = true;
                                              _rtcController.sdk.muteRemoteVideoStream(item.uid,true);
                                            }else{
                                              muteVideoMap.remove(item.uid);
                                              _rtcController.sdk.muteRemoteVideoStream(item.uid,false);
                                            }
                                          }),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Offstage(
                                      offstage:
                                          item.uid == meetModel.uid,
                                      child: IconButton(
                                          icon: Icon(
                                            muteMicMap[item.uid]==null? Icons.mic: Icons.mic_off,
                                            color: Colors.white,
                                            size: 36.0,
                                          ),
                                          onPressed: () {
                                            if(muteMicMap[item.uid] == null){
                                              muteMicMap[item.uid] = true;
                                              _rtcController.sdk.muteRemoteAudioStream(item.uid,true);
                                            }else{
                                              muteMicMap.remove(item.uid);
                                              _rtcController.sdk.muteRemoteAudioStream(item.uid,false);
                                            }
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
            new Align(
                child: new Container(
                  // grey box
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        color: Color.fromRGBO(245, 108, 108, 1),
                        onPressed: () {
                          _rtcController.sdk.muteAllRemoteAudioStreams(true);
                          userList.forEach((element) {
                            muteMicMap[element.uid] = true;
                          });
                          setState(() {

                          });
                        },
                        child:
                            Text('全体禁音', style: TextStyle(color: Colors.white)),
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(64, 158, 255, 1),
                        onPressed: () {
                          _rtcController.sdk.muteAllRemoteAudioStreams(false);
                          setState(() {
                            muteMicMap = {};
                          });
                        },
                        child: Text('解除全体禁音',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  height: 50.0,
                ),
                alignment: Alignment.bottomCenter),
          ],
        ),
      ),
    );
  }
}
