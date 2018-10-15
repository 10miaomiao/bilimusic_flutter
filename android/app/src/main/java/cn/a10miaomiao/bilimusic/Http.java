package cn.a10miaomiao.bilimusic;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class Http {

    public static void get(String str_url, CallBack callBack) {
        @SuppressLint("StaticFieldLeak")
        AsyncTask<String, Integer, String> mTasknew = new AsyncTask<String, Integer, String>() {
            @Override
            protected String doInBackground(String... strings) {
                try {
                    return Http.get(str_url);
                } catch (IOException e) {
                    e.printStackTrace();
                    return null;
                }
            }

            @Override
            protected void onPostExecute(String result) {
                callBack.callback(result);
            }

        };
        mTasknew.execute(str_url);
    }

    public static String get(String str_url) throws IOException {
        String resultData = "";
        URL url = null;
        try {
            url = new URL(str_url);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        if (url != null) {
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            InputStreamReader in = new InputStreamReader(urlConnection.getInputStream());
            BufferedReader buffer = new BufferedReader(in);
            String inputLine = "";
            while ((inputLine = buffer.readLine()) != null) {
                resultData += inputLine + "\n";
            }
            in.close();
            urlConnection.disconnect();
        }
        return resultData;
    }


    public static void loadImage(String imageUrl, BitmapCallback callback) {
        @SuppressLint("StaticFieldLeak")
        AsyncTask<String, Integer, Bitmap> mTasknew = new AsyncTask<String, Integer, Bitmap>() {
            @Override
            protected Bitmap doInBackground(String... strings) {
                if (imageUrl == null) {
                    return null;
                }
                URL url = null;
                Bitmap bitmap = null;
                try {
                    url = new URL(imageUrl);
                } catch (MalformedURLException e) {
                    e.printStackTrace();
                }
                try {
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setDoInput(true);
                    conn.connect();
                    InputStream is = conn.getInputStream();
                    bitmap = BitmapFactory.decodeStream(is);
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                return bitmap;
            }

            @Override
            protected void onPostExecute(Bitmap result) {
                callback.callback(result);
            }

        };
        mTasknew.execute(imageUrl);
    }

    public interface BitmapCallback {
        void callback(Bitmap bitmap);
    }

    public interface CallBack {
        void callback(String data);
    }
}
