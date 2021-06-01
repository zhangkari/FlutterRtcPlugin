import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:rtc_plugin/rtc/rtc_controller.dart';
import 'package:rtc_plugin/rtc/rtc_sdk_type.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;

class RTCView{
  static Widget buildView(ValueKey valueKey,int uid,bool isLocal,ValueChanged<int> onViewCreated){
    print("RTCView.buildView");
    if(RTCController().sdkType == RTCSDKType.Agora_RTC){
      print("RTCView.buildView.Agora_RTC");
      if(isLocal){
        print("RTCView.buildView.Agora_RTC.isLocal");
        return RtcLocalView.SurfaceView(
          key: valueKey,
          renderMode: VideoRenderMode.Fit,
          onPlatformViewCreated: onViewCreated,
        );
      }else{
        return RtcRemoteView.SurfaceView(
          key: valueKey,
          uid: uid,
          renderMode: VideoRenderMode.Fit,
          onPlatformViewCreated: onViewCreated,
          // onPlatformViewCreated: (viewId){
          //   onViewCreated.call(viewId);
          // },
        );
      }
    }else if(RTCController().sdkType  == RTCSDKType.Tencent_RTC){
      print("RTCView.buildView.Tencent_RTC");
      return TRTCCloudVideoView(
          key: valueKey,
          viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
          onViewCreated: onViewCreated
      );
    }
  }
}