package cn.a10miaomiao.bilimusic;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class BiliLyricLoader {
    private static final String TAG = BiliLyricLoader.class.getName();

    private List<Map<String, Object>> lyricList = new ArrayList<>();
    private boolean loading = true;

    private Context context;

    public BiliLyricLoader(Context context) {
        this.context = context;
    }

    public void loadLyric(String lyricUrl) {
        loading = true;
        lyricList.clear();
        sendUpdate();
        if ("".equals(lyricUrl)) {
            Map<String, Object> map = new HashMap<>();
            map.put("text", "暂无歌词");
            lyricList.add(map);
            loading = false;
            sendUpdate();
            return;
        }
        Http.get(lyricUrl, lyric -> {
            Map<String, Object> map0 = new HashMap<>();
            map0.put("text", "**暂不支持滚动**");
            lyricList.add(map0);
            LrcAnalyze lrcAnalyze = new LrcAnalyze(lyric);
            for (LrcAnalyze.LrcData lrc : lrcAnalyze.LrcGetList()){
                if (lrc.type != LrcAnalyze.OFFSET_ZONE){
                    Map<String, Object> map = new HashMap<>();
                    map.put("time", lrc.TimeMs);
                    map.put("text", lrc.LrcLine);
                    lyricList.add(map);
                }
            }
            loading = false;
            sendUpdate();
        });
    }

    public List<Map<String, Object>> getLyricList() {
        return lyricList;
    }

    public boolean isLoading() {
        return loading;
    }

    private void sendUpdate(){
        // 发送广播通知UI更新歌词
        Intent intent = new Intent(MusicService.ACTION);
        intent.putExtra("action", "update_lyric");
        context.sendBroadcast(intent);
    }
    private void sendIndex(int index){
        // 发送广播通知UI更新歌词
        Intent intent = new Intent(MusicService.ACTION);
        intent.putExtra("action", "update_index");
        intent.putExtra("index", index);
        context.sendBroadcast(intent);
    }
}
