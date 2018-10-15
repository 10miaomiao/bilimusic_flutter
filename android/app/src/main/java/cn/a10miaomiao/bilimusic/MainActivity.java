package cn.a10miaomiao.bilimusic;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";

    private PlayerBinder mPlayerBinder;

    private ServiceConnection mConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mPlayerBinder = (PlayerBinder) service;
            new MethodChannel(getFlutterView(), PlayerBinder.CHANNEL).setMethodCallHandler(mPlayerBinder);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.d(TAG, "onServiceDisconnected");
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        Intent serviceIntent = new Intent(this, MusicService.class);
        startService(serviceIntent);
        bindService(serviceIntent, mConnection, BIND_AUTO_CREATE);

        new MethodChannel(getFlutterView(), VolumeProviderPlugin.CHANNEL).setMethodCallHandler(new VolumeProviderPlugin(this));
        new MethodChannel(getFlutterView(), ToastProviderPlugin.CHANNEL).setMethodCallHandler(new ToastProviderPlugin(this));
        new EventChannel(getFlutterView(), "a10miaomiao.cn/lyric").setStreamHandler(
                new EventChannel.StreamHandler() {
                    private BroadcastReceiver mBroadcastReceiver;

                    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        mBroadcastReceiver = createBroadcastReceiver(events);
                        registerReceiver(mBroadcastReceiver, new IntentFilter(MusicService.ACTION));
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        // 对面不再接收
                        unregisterReceiver(mBroadcastReceiver);
                    }
                }
        );
    }

    private BroadcastReceiver createBroadcastReceiver(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Map<String, Object> map = new HashMap<>();
                if (intent.getExtras().containsKey("action")) {
                    String action = intent.getStringExtra("action");
                    map.put("action", action);
                    if ("update_index".equals(action)) {
                        map.put("index", intent.getIntExtra("index", -1));
                    }
                }
                events.success(map);
            }
        };
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //  mPlayerBinder.release();
        unbindService(mConnection);
    }
}
