import 'package:rtc_plugin/rtc/event/rtc_event.dart';

import 'role_enum.dart';

mixin RTCInterface{

  Future<void> init();

  ///退出房间
  Future<void> destroy();


  Future<void> setClientRole(RTCClientRole role); // 目标角色，默认为主播

  ///切换摄像头
  Future<void> switchCamera();

  // ///开启视频
  // Future<void> enableVideo();
  //
  // ///关闭视频
  // Future<void> disableVideo();
  //
  // ///开始视频预览
  // Future<void> startPreview();
  //
  // /// 结束视频预览
  // Future<void> stopPreview();

  ///开启或者关闭本地视频的采集预览
  Future<void> enableLocalVideo(bool enabled,int viewId);

  ///暂停/恢复本地视频流的推送
  Future<void> muteLocalVideoStream(bool muted);

  /// 暂停/恢复拉取指定远端视频流
  Future<void> muteRemoteVideoStream(int uid, bool muted);

  /// 暂停/恢复拉取所有远端视频流
  Future<void> muteAllRemoteVideoStreams(bool muted);

  ///开启或者关闭本地音频的采集预览
  Future<void> enableLocalAudio(bool enabled);

  ///暂停/恢复本地音频流的推送
  Future<void> muteLocalAudioStream(bool muted);

  /// 暂停/恢复拉取指定远端音频流
  Future<void> muteRemoteAudioStream(int uid, bool muted);

  /// 暂停/恢复拉取所有远端音频流
  Future<void> muteAllRemoteAudioStreams(bool muted);


  /// 显示远端视频或辅流
  Future<void> startRemoteView(int uid,int viewId);

  Future<void> stopRemoteView(int uid);




  ///加入房间
  Future<void> enterRoom(int uid,String token,String roomId,String extInfo);
  ///退出房间
  Future<void> exitRoom();

  Future<void> setEventHandler(RTCEventHandler eventHandler);

  /// 音频路由，即声音由哪里输出（true :扬声器、 false :听筒）
  Future<void> setEnableSpeakerphone(bool enabled);

  /// 决定了 onUserVoiceVolume 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；详细的回调规则请参考 onUserVoiceVolume 的注释说明。
  Future<void> enableAudioVolumeEvaluation(int intervalMs );

}