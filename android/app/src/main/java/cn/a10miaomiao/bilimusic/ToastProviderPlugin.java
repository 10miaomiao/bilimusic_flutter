package cn.a10miaomiao.bilimusic;

import android.app.Activity;
import android.widget.Toast;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ToastProviderPlugin implements MethodChannel.MethodCallHandler {

    public static final String CHANNEL = "a10miaomiao.cn/toast";

    Activity mActivity;

    public ToastProviderPlugin(Activity activity) {
        mActivity = activity;
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        int duration = Toast.LENGTH_SHORT;
        switch (methodCall.method) {
            case "showShortToast":
                duration = Toast.LENGTH_SHORT;
                break;
            case "showLongToast":
                duration = Toast.LENGTH_LONG;
                break;
            case "showToast":
                duration = methodCall.argument("duration");
                break;
        }
        Toast.makeText(mActivity, methodCall.argument("message"), duration).show();
        result.success(null);
    }
}
