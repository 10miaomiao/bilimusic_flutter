package cn.a10miaomiao.bilimusic;

import android.content.Context;
import android.content.Intent;
import android.util.JsonToken;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.IOException;
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

    public void loadLyric(int id, String lyricUrl) {
        loading = true;
        lyricList.clear();
        sendUpdate();
        if (lyricUrl != null && lyricUrl.length() != 0) {
            loadLyricByUrl(lyricUrl);
            return;
        }
        Http.get("https://www.bilibili.com/audio/music-service-c/web/song/info?sid=" + id, data -> {
            JSONTokener jsonParser = new JSONTokener(data);
            try {
                JSONObject json = (JSONObject) jsonParser.nextValue();
                if (json.getInt("code") == 0) {
                    JSONObject jsonData = json.getJSONObject("data");
                    loadLyricByUrl(jsonData.getString("lyric"));
                } else {
                    addText("加载失败");
                    loading = false;
                    sendUpdate();
                }
            } catch (Exception e) {
                addText("加载失败");
                loading = false;
                sendUpdate();
            }
        });
    }

    public void loadLyricByUrl(String lyricUrl) {
        if (lyricUrl == null && lyricUrl.length() == 0) {
            addText("暂无歌词");
            addText("歌词贡献及校对可发送邮件至");
            addText("audio@bilibili.com");
            loading = false;
            sendUpdate();
            return;
        }
        Http.get(lyricUrl, lyric -> {
            analyzeLyric(lyric);
        });
    }

    private void addText(String text){
        Map<String, Object> map = new HashMap<>();
        map.put("text", text);
        lyricList.add(map);
    }

    private void analyzeLyric(String lyric){
        if (lyric == null && lyric.length() == 0) {
            addText("暂无歌词");
            addText("歌词贡献及校对可发送邮件至audio@bilibili.com");
            loading = false;
            sendUpdate();
            return;
        }
        LrcAnalyze lrcAnalyze = new LrcAnalyze(lyric);
        if (lrcAnalyze.isNotTime()){
            addText("动手滚滚歌词吧＞﹏＜");
            addText(" ");
        }
        for (LrcAnalyze.LrcData lrc : lrcAnalyze.LrcGetList()){
            if (lrc.type == LrcAnalyze.LRC_ZONE){
                Map<String, Object> map = new HashMap<>();
                map.put("time", lrc.TimeMs);
                map.put("text", lrc.LrcLine);
                lyricList.add(map);
            }else if (lrc.type == LrcAnalyze.LRC_NOTIME){
                Map<String, Object> map = new HashMap<>();
                map.put("text", lrc.LrcLine);
                lyricList.add(map);
            }
        }
        loading = false;
        sendUpdate();
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
