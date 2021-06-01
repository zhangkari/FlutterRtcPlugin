
import 'package:rtc_plugin/rtc/audio_volume_info.dart';
import 'package:rtc_plugin/rtc/event/rtc_event.dart';
import 'package:rtc_plugin/rtc/role_enum.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';

import '../rtc_interface.dart';

class TencentRTC implements RTCInterface{

  String appid = "";
  TRTCCloud _trtcCloud;
  TXDeviceManager txDeviceManager;
  RTCEventHandler _rtcEventHandler;
  RTCClientRole _currentRole;
  RTCClientRole _willRole;

  TencentRTC(this.appid);

  @override
  Future<void> init() async{
    if(_trtcCloud == null) {
      _trtcCloud = await TRTCCloud.sharedInstance();
      initTXDeviceManager();
      txDeviceManager.switchCamera(true);
      _trtcCloud.registerListener(_onRtcListener);
    }
  }

  @override
  Future<void> enableLocalVideo(bool enabled,int viewId) async{
    if(enabled){
      initTXDeviceManager();
      _trtcCloud.setLocalRenderParams(TRTCRenderParams(fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT));
      _trtcCloud.startLocalPreview(await txDeviceManager.isFrontCamera(), viewId);
    }else{
      _trtcCloud.stopLocalPreview();
    }
  }

  @override
  Future<void> muteAllRemoteVideoStreams(bool muted) {
    _trtcCloud.muteAllRemoteVideoStreams(muted);
  }

  @override
  Future<void> muteLocalVideoStream(bool muted) {
    _trtcCloud.muteLocalVideo(muted);
  }

  @override
  Future<void> muteRemoteVideoStream(int uid, bool muted) {
    _trtcCloud.muteRemoteVideoStream(uid,muted);
  }

  @override
  Future<void> setClientRole(RTCClientRole role) {
    _willRole = role;
    if(role == RTCClientRole.Anchor){
      _trtcCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
    }else if(role == RTCClientRole.Audience){
      _trtcCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
    }
  }

  @override
  Future<void> enterRoom(int uid, String token, String roomId, String extInfo) {
    _trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: int.parse(appid), //应用Id
            userId: uid.toString(), // 用户Id
            userSig: token, // 用户签名
            role: TRTCCloudDef.TRTCRoleAnchor,
            roomId: 0,//房间Id
            strRoomId: roomId
        ),
        TRTCCloudDef.TRTC_APP_SCENE_LIVE);
  }

  @override
  Future<void> exitRoom() {
    _trtcCloud.exitRoom();
  }

  @override
  Future<void> destroy() {
    _trtcCloud.unRegisterListener(_onRtcListener);
    TRTCCloud.destroySharedInstance();
  }

  @override
  Future<void> setEventHandler(RTCEventHandler eventHandler) {
    _rtcEventHandler = eventHandler;
  }

  @override
  Future<void> enableLocalAudio(bool enabled) {
    if(enabled) {
      _trtcCloud?.startLocalAudio(TRTCCloudDef.TRTCSystemVolumeTypeVOIP);
    }else{
      _trtcCloud?.stopLocalAudio();
    }
  }

  @override
  Future<void> muteAllRemoteAudioStreams(bool muted) {
    _trtcCloud?.muteAllRemoteAudio(muted);
  }

  @override
  Future<void> muteLocalAudioStream(bool muted) {
    _trtcCloud?.muteLocalAudio(muted);
  }

  @override
  Future<void> muteRemoteAudioStream(int uid, bool muted) {
    _trtcCloud?.muteRemoteAudio(uid.toString(), muted);
  }




  /// 腾讯RTC事件回调
  _onRtcListener(type, param) async {
    if(_rtcEventHandler==null){
      return;
    }
    if (type == TRTCCloudListener.onError) {
      _rtcEventHandler?.errorCallback?.call(param['errCode'],param['errMsg']);
    }
    if (type == TRTCCloudListener.onEnterRoom) {
      if (param > 0) {
        _rtcEventHandler?.enterRoomSuccess?.call();
      }
    }
    if (type == TRTCCloudListener.onExitRoom) {
      if (param > 0) {
        _rtcEventHandler?.exitRoomSuccess?.call();
      }
    }
    // 远端用户进房
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      _rtcEventHandler?.remoteUserEnterRoom?.call(int.parse(param));
    }
    // 远端用户离开房间
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      _rtcEventHandler?.remoteUserExitRoom?.call(int.parse(param['userId']));
    }

    //远端用户是否存在可播放的主路画面（一般用于摄像头）
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      _rtcEventHandler?.onVideoVisible?.call(int.parse(param['userId']),param['available']);
    }
    if (type == TRTCCloudListener.onUserAudioAvailable) {
      _rtcEventHandler?.onAudioVisible?.call(int.parse(param['userId']),param['available']);
    }

    if (type == TRTCCloudListener.onSwitchRole) {
      if(param['errCode'] == 0){
        _currentRole = _willRole;
        _rtcEventHandler.onSwitchRole(_currentRole);
      }else{

      }
    }
    if (type == TRTCCloudListener.onNetworkQuality) {
      // _rtcEventHandler.networkQuality(param['userId'],param['localQuality'],param['remoteQuality']);
    }
    // if (type == TRTCCloudListener.connectionStateChanged) {
    //   _rtcEventHandler.connectionStateChanged(param['userId'],param['localQuality'],param['remoteQuality']);
    // }
    if (type == TRTCCloudListener.onWarning) {
      _rtcEventHandler?.warningCallback?.call(param['warningCode'],param['warningMsg']);
    }

    if (type == TRTCCloudListener.onUserVoiceVolume) {
      _rtcEventHandler?.audioVolumeCallback.call(convertSpeakers(param['userVolumes']),param['totalVolume']);
      print("***************************************");
      print("param = "+param.toString());
      print("***************************************");
    }
  }

  /// TRTC停止显示远端视频画面，同时不再拉取该远端用户的视频数据流。
  /// 指定要停止观看的 userId 的视频流类型
  ///* 高清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
  ///* 低清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
  ///* 辅流（屏幕分享）：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB
  @override
  Future<void> startRemoteView(int uid, int viewId) {
    _trtcCloud?.setRemoteRenderParams(uid.toString(), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, TRTCRenderParams(fillMode:TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT));
    _trtcCloud?.startRemoteView(uid.toString(), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, viewId);
  }

  @override
  Future<void> stopRemoteView(int uid) {
    _trtcCloud?.stopRemoteView(uid.toString(), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
  }

  initTXDeviceManager(){
    if(txDeviceManager==null){
      txDeviceManager = _trtcCloud.getDeviceManager();
    }
  }
  
  @override
  Future<void> switchCamera() async{
    initTXDeviceManager();
    bool isFrontCamera = await txDeviceManager.isFrontCamera();
    txDeviceManager.switchCamera(!isFrontCamera);
  }

  @override
  Future<void> setEnableSpeakerphone(bool enabled) {
    initTXDeviceManager();
    if(enabled){
      txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
    }else{
      txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
    }
  }

  @override
  Future<void> enableAudioVolumeEvaluation(int intervalMs) {
    _trtcCloud.enableAudioVolumeEvaluation(intervalMs);
  }

  List<RtcAudioVolumeInfo> convertSpeakers(List<dynamic> speakers) {
    List<RtcAudioVolumeInfo> infos = [];
    speakers?.forEach((element) {
      infos.add(RtcAudioVolumeInfo(int.parse(element['userId']), element['volume']));
    });
    return infos;
  }

}