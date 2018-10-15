package cn.a10miaomiao.bilimusic;

import android.os.Binder;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PlayerBinder extends Binder implements MethodChannel.MethodCallHandler {

    public static final String CHANNEL = "a10miaomiao.cn/player";

    private MusicService mMusicService;

    public PlayerBinder(MusicService musicService) {
        mMusicService = musicService;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        Map<String, Object> obj = new HashMap<>();
        switch (methodCall.method) {
            case "play":
                int index = methodCall.argument("index");
                mMusicService.play(index);
                break;
            case "pause":
                mMusicService.pause();
                break;
            case "resume":
                mMusicService.resume();
                break;
            case "next":
                mMusicService.next();
                break;
            case "seekTo":
                double progress = methodCall.argument("progress");
                mMusicService.seekTo(progress);
                break;
            case "previous":
                mMusicService.previous();
                break;
            case "getInfo":
                result.success(mMusicService.getInfo());
                break;
            case "setList":
                List<Map<String, Object>> list = methodCall.arguments();
                mMusicService.setList(list);
                break;
            case "getList":
                result.success(mMusicService.getList());
                break;
            case "getHistory":
                result.success(mMusicService.getHistory());
                break;
            case "setMode":
                int mode = methodCall.argument("mode");
                mMusicService.setMode(mode);
                break;
            case "getMode":
                obj.put("mode", mMusicService.getMode());
                result.success(obj);
                break;
            case "getLyric":
                result.success(mMusicService.getBiliLyricLoader().getLyricList());
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
