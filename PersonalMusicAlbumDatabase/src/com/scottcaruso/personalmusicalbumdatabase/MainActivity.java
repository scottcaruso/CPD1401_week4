package com.scottcaruso.personalmusicalbumdatabase;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.os.Bundle;
import android.app.Activity;
import android.database.Cursor;
import android.util.Log;
import android.view.Menu;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.parse.FindCallback;
import com.parse.Parse;
import com.parse.ParseAnalytics;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

public class MainActivity extends Activity {
	
	public static ArrayAdapter<HashMap<String,String>> masterArrray;
	public static ArrayAdapter<String> listOfGenres;
	public static ArrayAdapter<String> cloudIDs;
	public static Cursor masterCursor;
	public static SQLiteHelper sql;
	public static ListView listView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Parse.initialize(this, "GSJTIddEqF4RT6PmWi6VgKx63b5DWCDVDNRZyR9m", "O17apZByYdFumITsEpo8ndtjfFQ7MIJ3C7U0SYxt");
        setContentView(R.layout.activity_main);
        
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
  //The whatWeAreDoing string tells this function if we are checking at boot or if we are 
  //running a sync operation. Both are very similar in function, so they share the same 
  //framework.
   public void retrieveAllAlbums (final String whatWeAreDoing)
    {
	   ParseQuery<ParseObject> query = ParseQuery.getQuery("TestObject");
	   query.findInBackground(new FindCallback<ParseObject>() {
		   
		   @Override
	       public void done(List<ParseObject> albums, ParseException e) {
	           if (e == null) {
	               Log.d("score", "Retrieved " + albums.size() + " scores");
	               // Put the objects into the MasterList to create the first Master List.
	               for (ParseObject album : albums) {
		               HashMap<String,String> thisAlbum = new HashMap<String,String>();
		               thisAlbum.put("db_id", album.getObjectId());
		               thisAlbum.put("albumName", album.getString("album"));
		               thisAlbum.put("artistName", album.getString("artist"));
		               thisAlbum.put("date", album.getString("date"));
		               thisAlbum.put("genre", album.getString("genre"));
		               masterArrray.add(thisAlbum);
		               cloudIDs.add(album.getObjectId());
	               }
	               if (whatWeAreDoing == "Sync Data") {
	                    //If we are syncing data with the cloud, the final step
	            		//is to dump what is currently in memory and replace it
	            		//with the cloud data. This happens AFTER additions, modifications,
	            		//and deletions have occurred.
	                    sql.emptyDatabase();
	               }
	               fillDatabaseIfEmpty();
	           } else {
	               Log.d("score", "Error: " + e.getMessage());
	           }
	       }	
	   });
    }
	               
    public void fillDatabaseIfEmpty()
    {
    	
    }
}
