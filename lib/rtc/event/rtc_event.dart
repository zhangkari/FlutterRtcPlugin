import 'package:flutter/material.dart';
import 'package:rtc_plugin/rtc/role_enum.dart';

import '../audio_volume_info.dart';

typedef CodeMsgCallback = void Function(int code,String msg);
typedef ClientRoleCallback = void Function(RTCClientRole clientRole);
typedef ConnectionStateCallback = void Function(int code,int state);
typedef UserCallback = void Function(int uid);
typedef UserAndBoolCallback = void Function(int uid,bool b);
typedef UidWithMutedCallback = void Function(int uid, bool muted);
typedef NetworkQualityWithUidCallback = void Function(
    int uid, int txQuality, int rxQuality);
typedef RtcAudioVolumeCallback = void Function(
    List<RtcAudioVolumeInfo> speakers, int totalVolume);

class RTCEventHandler {
  CodeMsgCallback warningCallback;
  CodeMsgCallback errorCallback;

  VoidCallback enterRoomSuccess;
  VoidCallback exitRoomSuccess;

  UserCallback remoteUserEnterRoom;
  UserCallback remoteUserExitRoom;

  ClientRoleCallback onSwitchRole;

  ConnectionStateCallback connectionStateChanged;

  UserAndBoolCallback onVideoVisible;
  UserAndBoolCallback onAudioVisible;

  NetworkQualityWithUidCallback networkQuality;
  RtcAudioVolumeCallback audioVolumeCallback;


  RTCEventHandler(
      {this.warningCallback,
        this.errorCallback,
        this.enterRoomSuccess,
        this.exitRoomSuccess,
        this.remoteUserEnterRoom,
        this.remoteUserExitRoom,
        this.onSwitchRole,
        this.connectionStateChanged,
        this.networkQuality,
        this.onVideoVisible,
        this.onAudioVisible,
        this.audioVolumeCallback,
      });
}
