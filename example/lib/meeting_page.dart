import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rtc_plugin/rtc/event/rtc_event.dart';
import 'package:rtc_plugin/rtc/rtc_controller.dart';
import 'package:rtc_plugin/rtc/rtc_sdk_type.dart';
import 'package:rtc_plugin/rtc/view/rtc_view.dart';
import 'package:rtc_plugin_example/meeting_model.dart';
import 'package:rtc_plugin_example/tool.dart';
import 'package:provider/provider.dart';

import 'meeting_member.dart';
import 'member_list_page.dart';

class MeetingPage extends StatefulWidget {
  String roomId;
  RTCSDKType rtcsdkType;
  int uid;
  String appId;
  String token;

  MeetingPage(this.appId,this.token,this.roomId, this.rtcsdkType,this.uid);

  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>  with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollControl;
  int localViewId;
  List viewArr = [];
  RTCController _rtcController;

  MeetingModel meetModel;
  List<MeetingMember> userList = [];
  List<List<MeetingMember>> screenUserList = [];

  bool isSpeak = true; //是否是扬声器
  bool isOpenMic = true; //是否开启麦克风
  bool isOpenCamera = true; //是否开启摄像头

  @override
  void initState(){
    print("appid="+widget.appId);
    print("token="+widget.token);
    print("uid="+widget.uid.toString());
    print("roomId="+widget.roomId);
    print("sdkType="+widget.rtcsdkType.toString());
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    meetModel = context.read<MeetingModel>();
    meetModel.setUserId(widget.uid);
    initAndEnter();
    initScrollListener();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        const timeout = const Duration(milliseconds: 100); //10ms
        Timer(timeout, () {
          screenUserList = MeetingTool.getScreenList(userList);
          this.setState(() {});
        });
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        print("==paused video");
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          _rtcController.getSDK().exitRoom();
          return true;
        },
        child: Stack(
          children: <Widget>[
            ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: screenUserList.length,
                cacheExtent: 0,
                controller: scrollControl,
                itemBuilder: (BuildContext context, index) {
                  var item = screenUserList[index];
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Color.fromRGBO(19, 41, 75, 1),
                    child: Wrap(
                      children: List.generate(
                        item.length,
                            (index) => LayoutBuilder(
                          key: ValueKey(item[index].getID()),
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Size size = MeetingTool.getViewSize(
                                MediaQuery.of(context).size,
                                userList.length,
                                index,
                                item.length);
                            double width = size.width;
                            double height = size.height;
                            //双击放大后
                            // if (isDoubleTap) {
                            //   //其他视频渲染宽高设置为1，否则视频不推流
                            //   if (item[index]['size']['width'] == 0) {
                            //     width = 1;
                            //     height = 1;
                            //   }
                            // }
                            ValueKey valueKey = ValueKey((item[index].uid).toString()+(item[index].video?"1":"0"));
                            if(item[index].size.width>0){
                              width = item[index].size.width;
                              height = item[index].size.height;
                            }
                            print("5555555555555555555555555555=width:$width  height:$height");
                            return Container(
                              key: valueKey,
                              height: height,
                              width: width,
                              child: Stack(
                                key: valueKey,
                                children: <Widget>[
                                  renderView(item[index], valueKey),
                                  videoVoice(item[index])
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
            topSetting(),
            // beautySetting(),
            bottomSetting()
          ],
        ),
      ),
    );
  }

  Widget renderView(MeetingMember item, valueKey) {
    if (item.video) {
      return GestureDetector(
          key: valueKey,
          onDoubleTap: () {
            // doubleTap(item);
          },
          child: RTCView.buildView(valueKey,item.uid,item.uid==widget.uid,(viewId){
            if (item.uid == widget.uid) {
              print("11111111111111110000000000000111111111111111111110000000000000000011111 viewId=$viewId");
              _rtcController.getSDK().enableLocalVideo(true, viewId);
              setState(() {
                localViewId = viewId;
              });
            } else {
              _rtcController.getSDK().startRemoteView(item.uid,viewId);
            }
            viewArr.add(viewId);
          })
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: ClipOval(
          child: Image.network(
              'https://imgcache.qq.com/qcloud/public/static//avatar3_100.20191230.png',
              scale: 3.5),
        ),
      );
    }
  }

  /// 用户名、声音显示在视频层上面
  Widget videoVoice(MeetingMember item) {
    return Positioned(
      child: new Container(
          child: Row(children: <Widget>[
            Text(
              item.uid == widget.uid ? item.uid.toString() + "(me)": item.uid.toString(),
              style: TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: item.audio&&item.volume!=null&&item.volume>0,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.signal_cellular_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Visibility(
              visible: item.audio&&item.volume!=null&&item.volume>0,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(item.volume.toString(),
                  style: TextStyle(color: Colors.orange,fontSize: 20),
                ),
              ),
            ),
          ])),
      left: 24.0,
      bottom: 80.0,
    );
  }

  /// 顶部设置浮层
  Widget topSetting() {
    return new Align(
        child: new Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          // grey box
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    isSpeak ? Icons.volume_up : Icons.hearing,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    _rtcController.getSDK().setEnableSpeakerphone(!isSpeak);
                    setState(() {
                      isSpeak = !isSpeak;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    _rtcController.getSDK().switchCamera();
                  }),
              Text(widget.roomId,
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () async {
                  //弹出对话框并等待其关闭
                  bool delete = await showExitMeetingConfirmDialog();
                  if (delete != null) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "退出会议",
                  style: TextStyle(fontSize: 16.0),
                ),
              )
            ],
          ),
          height: 50.0,
          color: Color.fromRGBO(200, 200, 200, 0.4),
        ),
        alignment: Alignment.topCenter);
  }

  /// 底部设置浮层
  Widget bottomSetting() {
    return new Align(
        child: new Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          // grey box
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    isOpenMic ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    _rtcController.getSDK().enableLocalAudio(!isOpenMic);
                    setState(() {
                      isOpenMic = !isOpenMic;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    isOpenCamera ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    if (isOpenCamera) {
                      userList[0].video = false;
                      _rtcController.getSDK().enableLocalVideo(false, localViewId);
                      // if (isDoubleTap &&
                      //     doubleUserId == userList[0]['userId']) {
                      //   // 如果处在放大功能下，取消掉放大功能
                      //   doubleTap(userList[0]);
                      // }
                    } else {
                      userList[0].video = true;
                    }
                    setState(() {
                      isOpenCamera = !isOpenCamera;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.face,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    // this.setState(() {
                      // if (isShowBeauty) {
                      //   isShowBeauty = false;
                      // } else {
                      //   isShowBeauty = true;
                      // }
                    // });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberListPage(),
                      ),
                    );
                  }),
              IconButton(
                icon: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 36.0,
                ),
                onPressed: () {
                  // this.onShareClick();
                },
              ),
              // SettingPage()
            ],
          ),
          height: 70.0,
          color: Color.fromRGBO(200, 200, 200, 0.4),
        ),
        alignment: Alignment.bottomCenter);
  }

  // 屏幕左右滚动事件监听
  initScrollListener() {
    scrollControl = ScrollController();
    scrollControl.addListener(() {
      var firstScreen = screenUserList[0];
      if (scrollControl.offset >= scrollControl.position.maxScrollExtent &&
          !scrollControl.position.outOfRange) {
        for (var i = 1; i < firstScreen.length; i++) {
          if (i != 0) {
            // trtcCloud.stopRemoteView(firstScreen[i]['userId'],
            //     TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
          }
        }
      } else if (scrollControl.offset <=
          scrollControl.position.minScrollExtent &&
          !scrollControl.position.outOfRange) {
        for (var i = 1; i < firstScreen.length; i++) {
          if (i != 0) {
            // trtcCloud.startRemoteView(firstScreen[i]['userId'],
            //     TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewArr[i]);
          }
        }
      } else {
        // 滑动中
      }
    });
  }

  /// Add agora event handlers
  void _addEventHandlers() async{
    _rtcController.getSDK().setEventHandler(RTCEventHandler(errorCallback: (code,msg) {
      final info = 'onError: $code----$msg';
      showToast(info);
    }, exitRoomSuccess: () {
      final info = 'exitRoomSuccess';
      showToast(info);
    }, enterRoomSuccess: () {
      showToast("enterRoomSuccess");
    }, remoteUserEnterRoom: (uid) {
      final info = 'userJoined: $uid';
      showToast(info);
      userList.add(MeetingMember(uid:uid,video:false,audio:false,size:Size.zero));
      meetModel.setList(userList);
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
    }, remoteUserExitRoom: (uid) {
      final info = 'userOffline: $uid';
      showToast(info);
      for (var i = 0; i < userList.length; i++) {
        if (userList[i].uid == uid) {
          userList.removeAt(i);
        }
      }
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }, onAudioVisible: (uid, visible) {
      final info = 'onAudioVisible: $visible==$uid';
      showToast(info);
      if (visible) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i].uid == uid) {
            userList[i].audio = true;
            userList[i].volume = 0;
          }
        }
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i].uid == uid) {
            userList[i].audio = false;
            userList[i].volume = 0;
          }
        }
      }
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    },onVideoVisible: (uid, visible){
      final info = 'onVideoVisible: $visible==$uid';
      showToast(info);
      if (visible) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i].uid == uid) {
            userList[i].video = true;
          }
        }
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i].uid == uid) {
            // _rtcController.getSDK().stopRemoteView(
            //     userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
            userList[i].video = false;
          }
        }
      }
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    },audioVolumeCallback:(speakers,totalVolume){
      print("************************************");
      print("audioVolumeCallback = {totalVolume : $totalVolume , userVolumes:"+speakers.toString()+"}");
      speakers?.forEach((element) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i].uid == element.uid) {
            // _rtcController.getSDK().stopRemoteView(
            //     userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
            userList[i].volume = element.volume;
          }
        }
      });
      setState(() {

      });
      meetModel.setList(userList);

    }));
  }

  void initAndEnter() async{
    _rtcController = RTCController();
    await _rtcController.initRTCSDK(widget.rtcsdkType, widget.appId);
    _addEventHandlers();
    _rtcController.getSDK().enableAudioVolumeEvaluation(300);
    await _rtcController.getSDK().enterRoom(widget.uid, widget.token, widget.roomId, "");
    await _rtcController.getSDK().enableLocalAudio(isOpenMic);
    await _rtcController.getSDK().setEnableSpeakerphone(isSpeak);
    userList.add(MeetingMember(uid:widget.uid,video:isOpenCamera,audio:isOpenMic,size:Size.zero));
    setState(() {
      screenUserList = MeetingTool.getScreenList(userList);
    });
    meetModel.setList(userList);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rtcController.getSDK()?.exitRoom();
    _rtcController.getSDK()?.destroy();
    scrollControl.dispose();
    super.dispose();
  }

  // 提示浮层
  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }


  // 弹出退房确认对话框
  Future<bool> showExitMeetingConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确定退出会议?"),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
