package cn.a10miaomiao.bilimusic;

import android.graphics.BitmapFactory;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;

import java.util.Map;

public class MediaSessionManager {

    private static final String MY_MEDIA_ROOT_ID = "MediaSessionManager";

    private MusicService musicPlayService;
    private MediaSessionCompat mMediaSession;
    private PlaybackStateCompat.Builder stateBuilder;

    public MediaSessionManager(MusicService service) {
        this.musicPlayService = service;
        initSession();
    }

    public void initSession() {
        try {
            mMediaSession = new MediaSessionCompat(musicPlayService, MY_MEDIA_ROOT_ID);
            mMediaSession.setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS | MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS);
            stateBuilder = new PlaybackStateCompat.Builder()
                    .setActions(PlaybackStateCompat.ACTION_PLAY | PlaybackStateCompat.ACTION_PLAY_PAUSE
                            | PlaybackStateCompat.ACTION_SKIP_TO_NEXT | PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS);
            mMediaSession.setPlaybackState(stateBuilder.build());
            mMediaSession.setCallback(sessionCb);
            mMediaSession.setActive(true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updatePlaybackState(boolean isPlay, long position) {
        int state = isPlay ? PlaybackStateCompat.STATE_PLAYING : PlaybackStateCompat.STATE_PAUSED;
        stateBuilder.setState(state, position, 1.0f);
        mMediaSession.setPlaybackState(stateBuilder.build());
    }

    public void updateLocMsg() {
        try {
            //同步歌曲信息
            final MediaMetadataCompat.Builder md = new MediaMetadataCompat.Builder();
            final Map<String, Object> info = musicPlayService.getInfo();
            Http.loadImage((String) info.get("cover"), bitmap -> {
                md.putString(MediaMetadataCompat.METADATA_KEY_TITLE, (String) info.get("title"));
                md.putString(MediaMetadataCompat.METADATA_KEY_ARTIST, (String) info.get("author"));
                md.putBitmap(MediaMetadataCompat.METADATA_KEY_ALBUM_ART, bitmap);
                md.putLong(MediaMetadataCompat.METADATA_KEY_DURATION, (int) info.get("duration"));
                mMediaSession.setMetadata(md.build());
            });
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private MediaSessionCompat.Callback sessionCb = new MediaSessionCompat.Callback() {
        @Override
        public void onPlay() {
            super.onPlay();
            musicPlayService.resume();
        }

        @Override
        public void onPause() {
            super.onPause();
            musicPlayService.pause();
        }

        @Override
        public void onSkipToNext() {
            super.onSkipToNext();
            musicPlayService.next();
        }

        @Override
        public void onSkipToPrevious() {
            super.onSkipToPrevious();
            musicPlayService.previous();
        }

    };

    public void release() {
        mMediaSession.setCallback(null);
        mMediaSession.setActive(false);
        mMediaSession.release();
    }

}
