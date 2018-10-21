package cn.a10miaomiao.bilimusic;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MusicService extends Service implements MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener, MediaPlayer.OnErrorListener {
    public static final String ACTION = "cn.a10miaomiao.bilimusic.MusicService.ACTION";

    private PlayerBinder mBinder;
    private MediaPlayer mMediaPlayer;
    private MusicNotify mMusicNotify;
    private MediaSessionManager mMediaSessionManager;
    private List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
    private MusicHistoryDB historyDB;
    private BiliLyricLoader biliLyricLoader;
    private int index;
    private int mode; //播放模式

    /** AudiaoManager */
    private AudioManager mAudioManager;

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        if (mMediaPlayer == null)
            mMediaPlayer = new MediaPlayer();
        if (mBinder == null)
            mBinder = new PlayerBinder(this);
        if (historyDB == null)
            historyDB = new MusicHistoryDB(this, null);
        if (mMusicNotify == null)
            mMusicNotify = new MusicNotify(this, mMediaPlayer);
        if (mMediaSessionManager == null)
            mMediaSessionManager = new MediaSessionManager(this);
        mAudioManager = (AudioManager)getSystemService(AUDIO_SERVICE);
        mAudioManager.abandonAudioFocus(mAudioFocusListener);
        registerReceiver(mControlRecevier, new IntentFilter(MusicNotify.ACTION_CMD));
        IntentFilter filter = new IntentFilter();
        if (Build.VERSION.SDK_INT >= 21) {
            filter.addAction(AudioManager.ACTION_HEADSET_PLUG);
        } else {
            filter.addAction(Intent.ACTION_HEADSET_PLUG);
        }
        registerReceiver(headsetReceiver, filter);

        if (biliLyricLoader == null) {
            biliLyricLoader = new BiliLyricLoader(this);
        }
        mode = this.getSharedPreferences("BiliMusic", Context.MODE_PRIVATE)
                .getInt("mode", 0);

        this.mMusicNotify.updateForPlaying();
        historyDB.delete();
    }

    /**
     * 接受控制命令
     * 包括暂停、播放、上下首
     */
    private BroadcastReceiver mControlRecevier = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent == null)
                return;
            String action = intent.getAction();
            if (MusicNotify.ACTION_CMD.equals(action)) {
                int control = intent.getIntExtra("Control", -1);
                switch (control) {
                    case 0:
                        previous();
                        break;
                    case 1:
                        if (mMediaPlayer.isPlaying())
                            pause();
                        else
                            resume();
                        break;
                    case 2:
                        next();
                        break;
                }
            }
        }
    };
    /**
     * 耳机拔出
     */
    private BroadcastReceiver headsetReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            pause();
        }
    };
    /**
     * 监听AudioFocus的改变
     */
    private AudioManager.OnAudioFocusChangeListener mAudioFocusListener = new AudioManager.OnAudioFocusChangeListener() {
        @Override
        public void onAudioFocusChange(int focusChange) {
            switch (focusChange){
                case AudioManager.AUDIOFOCUS_GAIN ://获得AudioFocus

                    break;
                case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT: //短暂暂停

                    break;
                case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK: //减小音量

                    break;
                case AudioManager.AUDIOFOCUS_LOSS: //暂停
                    pause();
                    break;
            }
        }
    };


    @Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(mControlRecevier);
        unregisterReceiver(headsetReceiver);
        mControlRecevier = null;
        mMediaPlayer.stop();
        mMediaPlayer.reset();
        mMediaPlayer = null;
    }

    private void startPlay(String playUrl, Map<String, String> header) throws IOException {
        mMediaPlayer.reset();
        mMediaPlayer.setOnPreparedListener(this);
        mMediaPlayer.setOnCompletionListener(this);
        mMediaPlayer.setOnErrorListener(this);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
            mMediaPlayer.setDataSource(this, Uri.parse(playUrl), header);//设置播放的数据源。
        }
        mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        // mediaPlayer.prepare();//同步的准备方法。
        try {
            mMediaPlayer.prepareAsync(); //异步的准备
        } catch (IllegalStateException e) {
            Toast.makeText(this, "播放失败了喵", Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }
    }

    private void loadMusic(int index) {
        this.index = index;
        this.mMusicNotify.updateForPlaying();
        this.mMediaSessionManager.updateLocMsg();
        mMediaPlayer.stop();
        final int id = (int) list.get(this.index).get("id");
        biliLyricLoader.loadLyric(
                id,
                (String) list.get(index).get("lyric")
        );
        historyDB.deleteById(id);
        historyDB.insert(list.get(this.index));

        mAudioManager.requestAudioFocus(mAudioFocusListener,AudioManager.STREAM_MUSIC,AudioManager.AUDIOFOCUS_GAIN);

        String url = "https://www.bilibili.com/audio/music-service-c/web/url?sid=" + id + "&privilege=2&quality=2";
        Http.get(url, data -> {
            JSONTokener jsonParser = new JSONTokener(data);
            try {
                JSONObject json = (JSONObject) jsonParser.nextValue();
                if (json.getInt("code") == 0) {
                    JSONObject jsonData = json.getJSONObject("data");
                    JSONArray cdns = jsonData.getJSONArray("cdns");
                    String playUrl = cdns.getString(0);
                    Map<String, String> header = new HashMap<>();
                    header.put("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36");
                    header.put("Referer", "https://www.bilibili.com/audio/au" + id);
                    startPlay(playUrl, header);
                } else {
                    Toast.makeText(MusicService.this, "发生错误", Toast.LENGTH_LONG).show();
                }
            } catch (JSONException e) {
                Toast.makeText(MusicService.this, "发生错误", Toast.LENGTH_LONG).show();
                e.printStackTrace();
            } catch (IOException e) {
                Toast.makeText(MusicService.this, "发生错误", Toast.LENGTH_LONG).show();
                e.printStackTrace();
            }
        });
    }

    public void pause() {
        if (mMediaPlayer.isPlaying()) {
            mMediaPlayer.pause();
        }
        this.mMusicNotify.updateForPlaying();
        this.mMediaSessionManager.updatePlaybackState(false, mMediaPlayer.getCurrentPosition());
    }

    public void resume() {
        if (!mMediaPlayer.isPlaying()) {
            mMediaPlayer.start();
        }
        this.mMusicNotify.updateForPlaying();
        this.mMediaSessionManager.updatePlaybackState(true, mMediaPlayer.getCurrentPosition());
    }

    public void seekTo(double progress) {
        int msec = (int) (mMediaPlayer.getDuration() * progress);
        mMediaPlayer.seekTo(msec);
    }

    public int getRandom(int min, int max) {
        Random random = new Random();
        int i = random.nextInt(max) % (max - min + 1) + min;
        return i;
    }

    public void next() {
        int index = MusicService.this.index + 1;
        switch (mode) {
            case 0:
                // 顺序播放
                if (index < list.size() && index > 0) {
                    loadMusic(index);
                }
                break;
            case 1:
                // 列表循环
                if (index >= list.size()) {
                    index = 0;
                }
                if (list.size() > 0) {
                    loadMusic(index);
                }
                break;
            case 2:
                // 单曲循环
                loadMusic(this.index);
                break;
            case 3:
                // 随机播放
                index = getRandom(0, list.size() - 1);
                loadMusic(index);
                break;
        }
        this.mMusicNotify.updateForPlaying();
    }


    public void previous() {
        int index = MusicService.this.index - 1;
        if (index >= 0 && list.size() > 0) {
            loadMusic(index);
        }
        this.mMusicNotify.updateForPlaying();
    }

    @Override
    public void onCompletion(MediaPlayer mp) {
        next();
    }

    @Override
    public void onPrepared(MediaPlayer mp) {
        mp.start();
        this.mMusicNotify.updateForPlaying();
        this.mMediaSessionManager.updateLocMsg();
        this.mMediaSessionManager.updatePlaybackState(mp.isPlaying(), mp.getCurrentPosition());
    }

    @Override
    public boolean onError(MediaPlayer mp, int what, int extra) {
        return true;
    }

    public void play(int index) {
        if (index < list.size()) {
            loadMusic(index);
        } else {
            Toast.makeText(MusicService.this, "发生错误", Toast.LENGTH_LONG).show();
        }
    }

    public Map<String, Object> getInfo() {
        Map<String, Object> map = new HashMap<>();
        if (mMediaPlayer != null && index < list.size()) {
            Map<String, Object> info = list.get(index);
            map.put("position", mMediaPlayer.getCurrentPosition());
            map.put("duration", mMediaPlayer.getDuration());
            map.put("isPlaying", mMediaPlayer.isPlaying());
            map.put("title", info.get("title"));
            map.put("author", info.get("author"));
            map.put("cover", info.get("cover"));
            map.put("index", index);
        }
        return map;
    }

    public void setList(List<Map<String, Object>> list) {
        this.list = list;
    }

    public void setMode(int mode) {
        this.mode = mode;
        this.getSharedPreferences("BiliMusic", Context.MODE_PRIVATE)
                .edit()
                .putInt("mode", mode)
                .commit();
    }

    public int getMode() {
        return mode;
    }

    public List<Map<String, Object>> getList() {
        return list;
    }

    public List<Map<String, Object>> getHistory() {
        return historyDB.queryAll();
    }

    public void stop() {
        mMediaPlayer.stop();
        this.mMusicNotify.updateForPlaying();
    }

    public void release() {
        mMediaPlayer.release();
    }

    public BiliLyricLoader getBiliLyricLoader() {
        return biliLyricLoader;
    }


}
