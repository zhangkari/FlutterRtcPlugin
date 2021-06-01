import 'package:rtc_plugin/rtc/event/rtc_event.dart';

import 'agora_rtc/agora_rtc.dart';
import 'rtc_interface.dart';
import 'rtc_sdk_type.dart';
import 'tencent_rtc/tencent_rtc.dart';

class RTCController{
  static RTCController _rtcController;
  bool _isInited = false;
  RTCInterface _rtcInterface;
  RTCSDKType _rtcsdkType;

  factory RTCController() => _instance();

  RTCController._();

  /// 创建 TRTCController 单例。
  static RTCController _instance() {
    if (_rtcController == null) {
      _rtcController = RTCController._();
    }
    return _rtcController;
  }

  RTCInterface get sdk => getSDK();
  RTCSDKType get sdkType => getSDKType();

  Future<bool> initRTCSDK(RTCSDKType rtcsdkType,String appid) async{
    if(rtcsdkType == null){
      print("rtcsdkType not null");
      return false;
    }
    if(appid == null || appid.length<1){
      print("appid not empty");
      return false;
    }
    // if(_isInited){
    //   print("initRTCSDK can only be called once");
    //   return false;
    // }
    // if(_rtcInterface!=null){
    //   _rtcInterface.destroy();
    // }
    _rtcsdkType = rtcsdkType;
    _isInited = true;
    if(rtcsdkType == RTCSDKType.Agora_RTC){
      _rtcInterface = new Agora_RTC(appid);
      await _rtcInterface.init();
      return true;
    }else if(rtcsdkType == RTCSDKType.Tencent_RTC){
      _rtcInterface = new TencentRTC(appid);
      await _rtcInterface.init();
      return true;
    }else{
      _isInited = false;
    }
  }

  RTCInterface getSDK(){
    if(_rtcInterface==null){
      print("RTCController.getSDK : Please call initRTCSDK");
    }
    return _rtcInterface;
  }

  RTCSDKType getSDKType(){
    if(_rtcsdkType==null){
      print("RTCController.getSDKType : Please call initRTCSDK");
    }
    return _rtcsdkType;
  }

}