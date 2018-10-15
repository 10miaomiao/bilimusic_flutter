package cn.a10miaomiao.bilimusic;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.os.AsyncTask;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.support.v4.media.session.MediaSessionCompat;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;
import java.util.function.Consumer;

public class MusicNotify {
    public final static String ACTION_CMD = "cn.a10miaomiao.bilimusic.MusicNotify";

    MusicService mMusicService;
    MediaPlayer mMediaPlayer;
    NotificationManager manager;
    NotificationCompat.Builder builder;
    final int notificationID = 2333;

    public MusicNotify(MusicService musicService, MediaPlayer mediaPlayer) {
        this.mMusicService = musicService;
        this.mMediaPlayer = mediaPlayer;
        manager = (NotificationManager) mMusicService.getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel mChannel = new NotificationChannel("cn.a10miaomiao.bilimiusic.control", "MiusicControl", NotificationManager.IMPORTANCE_LOW);
            manager.createNotificationChannel(mChannel);
            builder = new NotificationCompat.Builder(mMusicService, "cn.a10miaomiao.bilimiusic.control");
        } else {
            builder = new NotificationCompat.Builder(mMusicService);
        }
    }

    public void updateForPlaying() {
        String _title = "BiliMusic";
        String _subTitle = "哔哩哔哩音乐姬";
        Map<String, Object> info = mMusicService.getInfo();
        if (!mMediaPlayer.isPlaying()){
            manager.cancel(notificationID);
            return;
        }
        if (info.containsKey("title"))
            _title = (String) info.get("title");
        if (info.containsKey("author"))
            _subTitle = (String) info.get("author");
        final String title = _title;
        final String subTitle = _subTitle;
        Http.loadImage((String) info.get("cover"), bitmap -> {
            updateWithBitmap(bitmap == null
                            ? BitmapFactory.decodeResource(mMusicService.getResources(), R.drawable.bilimusic)
                            : bitmap,
                    title, subTitle);
        });
    }

    private void updateWithBitmap(Bitmap bitmap, String title, String subTitle) {
        int playPauseIcon = mMediaPlayer.isPlaying() ? R.drawable.ic_pause_black_24dp : R.drawable.ic_play_arrow_black_24dp;
        builder.setContentTitle(title);
        builder.setContentText(subTitle);
        builder.setSmallIcon(R.drawable.bili_default_image_tv);
        builder.setLargeIcon(bitmap);
        //builder.setDefaults(NotificationCompat.DEFAULT_ALL);
        builder.setShowWhen(false);
        builder.setOngoing(mMediaPlayer.isPlaying());
        Intent intent = new Intent(mMusicService, MainActivity.class);
        PendingIntent pIntent = PendingIntent.getActivity(mMusicService, 1, intent, 0);
        builder.setContentIntent(pIntent);
        //第一个参数是图标资源id 第二个是图标显示的名称，第三个图标点击要启动的PendingIntent
        builder.addAction(R.drawable.ic_skip_previous_black_24dp, "",
                PendingIntent.getBroadcast(mMusicService, 0, getControlIntent(0), PendingIntent.FLAG_UPDATE_CURRENT));
        builder.addAction(playPauseIcon, "",
                PendingIntent.getBroadcast(mMusicService, 1, getControlIntent(1), PendingIntent.FLAG_UPDATE_CURRENT));
        builder.addAction(R.drawable.ic_skip_next_black_24dp, "",
                PendingIntent.getBroadcast(mMusicService, 2, getControlIntent(2), PendingIntent.FLAG_UPDATE_CURRENT));
        android.support.v4.media.app.NotificationCompat.MediaStyle style = new android.support.v4.media.app.NotificationCompat.MediaStyle();
        style.setMediaSession(new MediaSessionCompat(mMusicService, "MediaSession",
                new ComponentName(mMusicService, Intent.ACTION_MEDIA_BUTTON), null).getSessionToken());
        //CancelButton在5.0以下的机器有效
        style.setCancelButtonIntent(pIntent);
        style.setShowCancelButton(true);
        //设置要现实在通知右方的图标 最多三个
        style.setShowActionsInCompactView(0, 1, 2);
        builder.setStyle(style);
        Notification notification = builder.build();
        manager.notify(notificationID, notification);
    }

    private Intent getControlIntent(int control) {
        return new Intent(MusicNotify.ACTION_CMD)
                .putExtra("FromNotify", true)
                .putExtra("Control", control);
    }





}
