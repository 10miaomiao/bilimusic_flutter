package cn.a10miaomiao.bilimusic;

import android.util.Base64;
import android.util.Log;

import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;

import javax.crypto.Cipher;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class RSAProviderPlugin implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "a10miaomiao.cn/rsa";

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "decryptByPublicKey":
                String data = methodCall.argument("data");
                String publicKey = methodCall.argument("publicKey");
                try {
                    publicKey = publicKey.replaceAll("-----BEGIN PUBLIC KEY-----\n", "")
                            .replaceAll("-----END PUBLIC KEY-----\n", "");
                    String cipher= decryptByPublicKey(data, publicKey);
                    result.success(cipher);
                } catch (Exception e) {
                    e.printStackTrace();
                    result.error("Exception encountered", methodCall.method, e);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 公钥解密
     *
     * @param data      待解密数据
     * @param publicKey 密钥
     * @return byte[] 解密数据
     */
    public static String decryptByPublicKey(String data, String publicKey) throws Exception {
        byte[] keyBytes = Base64.decode(publicKey, Base64.NO_WRAP);
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");

        PublicKey pubKey = keyFactory.generatePublic(keySpec);

        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        cipher.init(Cipher.ENCRYPT_MODE, pubKey);
        byte[] mi = cipher.doFinal(data.getBytes());

        return Base64.encodeToString(mi, Base64.DEFAULT);

    }

}
