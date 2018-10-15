package cn.a10miaomiao.bilimusic;

import android.app.Activity;
import android.media.AudioManager;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static android.content.Context.AUDIO_SERVICE;

public class VolumeProviderPlugin implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "a10miaomiao.cn/volume";

    AudioManager mAudioManager;
    int maxVolume = 10;
    int volume = 0;
    double num = 0.0;

    public VolumeProviderPlugin(Activity activity) {
        mAudioManager = (AudioManager) activity.getSystemService(AUDIO_SERVICE);
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "setVolume":
                num = methodCall.argument("volume");
                volume = (int) (num * maxVolume);
                mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, 0);
                break;
            case "getVolume":
                maxVolume = mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
                volume = mAudioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
                num = (double) volume / (double) maxVolume;
                Map<String, Object> obj = new HashMap<>();
                obj.put("volume", num);
                result.success(obj);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
