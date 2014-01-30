package com.scottcaruso.personalmusicalbumdatabase;

import java.util.HashMap;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class SQLiteHelper extends SQLiteOpenHelper {

	private static final int DB_VER = 1;
	private static final String DB_NAME = "AlbumDB";
	
    private static final String TABLE_ALBUMS = "albums";
    private static final String TABLE_GENRES = "genres";

    private static final String KEY_ID = "id";
    private static final String DB_ID = "db_id";
    private static final String KEY_ALBUMNAME = "name";
    private static final String KEY_ARTIST = "artist";
    private static final String KEY_YEAR = "year";
    private static final String KEY_GENRE = "genre";

    private static final String[] COLUMNS = {KEY_ID,DB_ID,KEY_ALBUMNAME,KEY_ALBUMNAME,KEY_YEAR,KEY_GENRE};
	
	public SQLiteHelper(Context context){
		super(context, DB_NAME, null, DB_VER);
	}
	
	 @Override
	 public void onCreate(SQLiteDatabase db) {
	 
		 String CREATE_TABLE_ALBUMS = "CREATE TABLE IF NOT EXISTS " + TABLE_ALBUMS + 
		 		"(id INTEGER PRIMARY KEY AUTOINCREMENT," +
		 		"db_id varchar(50), album_name varchar(50), artist_name varchar(50), album_year INTEGER, genre_code INTEGER, is_edited INTEGER);";
		 String CREATE_TABLE_GENRES = "CREATE TABLE genres (id INTEGER PRIMARY KEY," +
		 		"genre_id INTEGER, role varchar(20));";
		 db.execSQL(CREATE_TABLE_ALBUMS);
		 db.execSQL(CREATE_TABLE_GENRES);
	 }
	 
	 @Override
	 public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
	        
		 db.execSQL("DROP TABLE IF EXISTS " + TABLE_ALBUMS);
	 
		 this.onCreate(db);
	 }
	 
	 public Cursor getAllAlbums() {
	       String query = "SELECT * FROM albums;";
	 
	       SQLiteDatabase db = this.getWritableDatabase();
	       Cursor cursor = db.rawQuery(query, null);
	       db.close();
	       	        
	       return cursor;  
	   }
	 
	 public void addItemToLocalDatabase(String sqlString)
	 {
		 SQLiteDatabase db = this.getWritableDatabase();
		 db.execSQL(sqlString);
		 db.close();
	 }
	 
	 public Cursor getNewAlbums() {
	       String query = "SELECT * FROM albums WHERE database_id=\"NEW\";";

	       SQLiteDatabase db = this.getWritableDatabase();
	       Cursor cursor = db.rawQuery(query, null);
	       db.close();
	       	        
	       return cursor;
	   }
	 
	 public Cursor getEditedItems() {

	       String query = "SELECT * FROM albums WHERE is_edited=1;";
	 
	       SQLiteDatabase db = this.getWritableDatabase();
	       Cursor cursor = db.rawQuery(query, null);
	       db.close();
	       	        
	       return cursor;    
	   }
	 
	 public void emptyDatabase() {
		 
		 String query = "DELETE FROM albums;VACUUM;";
		 SQLiteDatabase db = this.getWritableDatabase();
		 db.execSQL(query);
		 db.close();
	 }
	 
	 public void modifyItemInDatabase(String dbID, HashMap<String,String> data)
	 {
		 String newTitle = data.get("title");
		 String newArtist = data.get("artist");
		 String newYear = data.get("date");
		 String newGenre = data.get("genre");
		 String sqlString = "UPDATE albums SET album_name=\""+newTitle+"\",artist_name=\""+newArtist+
				"\",album_year=\""+newYear+"\",album_genre=\""+newGenre+"\",is_edited=1 WHERE db_id=\""+dbID+"\");";
		 
		 SQLiteDatabase db = this.getWritableDatabase();
		 db.execSQL(sqlString); 
		 db.close();
	 }
	 
	 public void removeItemInDatabase(String dbID)
	 {
		 String sqlString = "DELETE FROM albums WHERE database_id=\""+dbID+"\";";
		 
		 SQLiteDatabase db = this.getWritableDatabase();
		 db.execSQL(sqlString); 
		 db.close();
	 }
	 
	 public Cursor getFilteredResults(int filterParam) {
	       String query = "SELECT * FROM albums WHERE genre_code="+filterParam+";";
	 
	       SQLiteDatabase db = this.getWritableDatabase();
	       Cursor cursor = db.rawQuery(query, null);
	       db.close();
	       	        
	       return cursor;  
	   } 
}
