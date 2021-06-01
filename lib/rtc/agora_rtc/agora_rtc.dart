
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:rtc_plugin/rtc/event/rtc_event.dart';
import 'package:rtc_plugin/rtc/role_enum.dart';

import '../audio_volume_info.dart';
import '../rtc_interface.dart';

class Agora_RTC implements RTCInterface{

  String appid ="";
  RtcEngine _engine;

  RTCEventHandler _rtcEventHandler;

  Agora_RTC(this.appid);

  @override
  Future<void> init() async{
    if(_engine == null){
      _engine = await RtcEngine.createWithConfig(RtcEngineConfig(appid,areaCode: AreaCode.GLOB));
      // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
      // await _engine.setClientRole(ClientRole.Broadcaster);
      _addAgoraEventHandlers();
      // VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
      // configuration.dimensions = VideoDimensions(1920, 1080);
      // await _engine.setVideoEncoderConfiguration(configuration);
    }
  }

  @override
  Future<void> enableLocalVideo(bool enabled,int viewId) async{
    if(enabled){
      _engine.enableVideo();
      _engine.startPreview();
    }else{
      _engine.stopPreview();
    }
    _engine.enableLocalVideo(enabled);
  }

  @override
  Future<void> muteAllRemoteVideoStreams(bool muted) {
    _engine.muteAllRemoteVideoStreams(muted);
  }

  @override
  Future<void> muteLocalVideoStream(bool muted) {
    _engine.muteLocalVideoStream(muted);
  }

  @override
  Future<void> muteRemoteVideoStream(int uid, bool muted) {
    _engine.muteRemoteVideoStream(uid,muted);
  }

  @override
  Future<void> setClientRole(RTCClientRole role) {
    if(role == RTCClientRole.Anchor){
      _engine.setClientRole(ClientRole.Broadcaster);
    }else if(role == RTCClientRole.Audience){
      _engine.setClientRole(ClientRole.Audience);
    }
  }

  @override
  Future<void> switchCamera() {
    _engine.switchCamera();
  }

  @override
  Future<void> enterRoom(int uid, String token, String roomId, String extInfo) async{
    _engine.joinChannel(token, roomId, null, uid);
  }

  @override
  Future<void> exitRoom() async{
    _engine?.leaveChannel();
  }

  @override
  Future<void> destroy() {
    _engine.setEventHandler(null);
    _engine?.destroy();
  }

  @override
  Future<void> setEventHandler(RTCEventHandler eventHandler) {
    _rtcEventHandler = eventHandler;
  }

  @override
  Future<void> enableLocalAudio(bool enabled) {
    _engine.enableLocalAudio(enabled);
  }

  @override
  Future<void> muteAllRemoteAudioStreams(bool muted) {
    _engine.muteAllRemoteAudioStreams(muted);
  }

  @override
  Future<void> muteLocalAudioStream(bool muted) {
    _engine.muteLocalAudioStream(muted);
  }

  @override
  Future<void> muteRemoteAudioStream(int uid, bool muted) {
    _engine.muteRemoteAudioStream(uid,muted);
  }

  @override
  Future<void> startRemoteView(int uid, int viewId) {
  }

  @override
  Future<void> stopRemoteView(int uid) {
  }


  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      int index = code.index;
      print("ssssssssssssssssssssssssssssssssssssssssss=errorcode=$code  index = $index");
      _rtcEventHandler?.errorCallback?.call(code.index,"");
    }, warning:(code){
      _rtcEventHandler?.warningCallback?.call(code.index,"");
    },joinChannelSuccess: (channel, uid, elapsed) {
      _rtcEventHandler?.enterRoomSuccess?.call();
    }, leaveChannel: (stats) {
      _rtcEventHandler?.exitRoomSuccess?.call();
    }, userJoined: (uid, elapsed) {
      _rtcEventHandler?.remoteUserEnterRoom?.call(uid);
    }, userOffline: (uid, elapsed) {
      _rtcEventHandler?.remoteUserExitRoom?.call(uid);
    }, remoteVideoStateChanged: (uid, state, reason, elapsed) {
      if(state == VideoRemoteState.Stopped){
        _rtcEventHandler?.onVideoVisible?.call(uid,false);
      }else if(state == VideoRemoteState.Decoding){
        _rtcEventHandler?.onVideoVisible?.call(uid,true);
      }
    },remoteAudioStateChanged: (uid, state, reason, elapsed){
      if(state == AudioRemoteState.Stopped){
        _rtcEventHandler?.onAudioVisible?.call(uid,false);
      }else if(state == AudioRemoteState.Decoding){
        _rtcEventHandler?.onAudioVisible?.call(uid,true);
      }
    },connectionStateChanged: (type,reason){
      _rtcEventHandler?.connectionStateChanged?.call(0,0);
    },clientRoleChanged: (oldRole,newRole){
      _rtcEventHandler?.onSwitchRole?.call(newRole==ClientRole.Broadcaster?RTCClientRole.Anchor:RTCClientRole.Audience);
    },networkQuality: (uid,tx,rx){
      _rtcEventHandler?.networkQuality?.call(uid,tx.index,rx.index);
    },audioVolumeIndication:(speakers, totalVolume){
      _rtcEventHandler?.audioVolumeCallback.call(convertSpeakers(speakers),totalVolume);
    }));
  }

  @override
  Future<void> setEnableSpeakerphone(bool enabled) {
    _engine?.setEnableSpeakerphone(enabled);
  }

  @override
  Future<void> enableAudioVolumeEvaluation(int intervalMs) {
    _engine?.enableAudioVolumeIndication(intervalMs, 3, false);
  }

  List<RtcAudioVolumeInfo> convertSpeakers(List<AudioVolumeInfo> speakers) {
    List<RtcAudioVolumeInfo> infos = [];
    speakers?.forEach((element) {
      infos.add(RtcAudioVolumeInfo(element.uid, element.volume));
    });
    return infos;
  }

}