package cn.a10miaomiao.bilimusic;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MusicHistoryDB extends SQLiteOpenHelper {
    private static final int VERSION = 3;
    private static final String DB_NAME = "Music";
    private static final String TABLE_NAME = "MusicHistory";

    private static final String CREATE_TABLE = "create table if not exists " + TABLE_NAME
            + " ([id] int,[title] text,[author] text,[cover] text,[lyric] text,[time] TIMESTAMP default (datetime('now', 'localtime')))";

    public MusicHistoryDB(Context context, SQLiteDatabase.CursorFactory factory) {
        super(context, DB_NAME, factory, VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CREATE_TABLE); //创建表
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("drop table if exists " + TABLE_NAME);
        db.execSQL(CREATE_TABLE); //创建表
    }

    /**
     * 插入数据到数据库
     */
    public void insert(Map<String, Object> info) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        //往ContentValues对象存放数据，键-值对模式
        cv.put("id", (int) info.get("id"));
        cv.put("title", (String) info.get("title"));
        cv.put("author", (String) info.get("author"));
        cv.put("cover", (String) info.get("cover"));
        cv.put("lyric", (String) info.get("lyric"));
        //调用insert方法，将数据插入数据库
        db.insert(TABLE_NAME, null, cv);
        //关闭数据库
        db.close();
    }

    /**
     * 查询全部记录
     */
    public List<Map<String, Object>> queryAll() {
        List<Map<String, Object>> historys = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        //查询表中的数据
        Cursor cursor = db.query(TABLE_NAME, null, null, null, null, null, "`time` desc limit 100 offset 0");
        final int idIndex = cursor.getColumnIndex("id");
        final int titleIndex = cursor.getColumnIndex("title");
        final int authorIndex = cursor.getColumnIndex("author");
        final int coverIndex = cursor.getColumnIndex("cover");
        final int lyricIndex = cursor.getColumnIndex("lyric");
        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", cursor.getInt(idIndex));
            item.put("title", cursor.getString(titleIndex));
            item.put("author", cursor.getString(authorIndex));
            item.put("cover", cursor.getString(coverIndex));
            item.put("lyric", cursor.getString(lyricIndex));
            historys.add(item);
            cursor.moveToNext();
        }
        cursor.close();//关闭结果集
        db.close();//关闭数据库对象
        return historys;
    }

    /**
     * 删除某条数据
     */
    public void deleteById(int id) {
        SQLiteDatabase db = getWritableDatabase();
        db.delete(TABLE_NAME, "`id`=?", new String[]{String.valueOf(id)});
        db.close();
    }

    public int count(){
        SQLiteDatabase db = getReadableDatabase();
        Cursor cursor = db.rawQuery("select count(`id`) from " + TABLE_NAME, new String[]{});
        cursor.moveToFirst();
        int count = cursor.getInt(0);
        db.close();
        return count;
    }

    /**
     * 只保留前max条数据
     */
    public void delete() {
        int count = count();
        int max = 100;
        if (count <= max)
            return;
        SQLiteDatabase db = getReadableDatabase();
        //查询表中的数据
        Cursor cursor = db.query(TABLE_NAME, null, null, null, null, null, "`time` asc limit "+ (count - max) +" offset 0");
        cursor.moveToFirst();
        int index = cursor.getColumnIndex("id");
        while (!cursor.isAfterLast()) {
            deleteById(cursor.getInt(index));
            cursor.moveToNext();
        }
        cursor.close();
        db.close();
    }


}
