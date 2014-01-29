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
import android.widget.Toast;

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
        retrieveAllAlbums("Startup");
        
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
    	Cursor currentDB = sql.getAllAlbums();
    	int numberOfItems = currentDB.getCount();
    	if (numberOfItems == 0)
    	{
    		int numberOfRecords = masterArrray.getCount();
            for (int x = 0; x < numberOfRecords; x++)
            {
                String stringToAdd = "Test";//[self createInsertString:[masterList objectAtIndex:x]];
                sql.addItemToDatabase(stringToAdd);
            }
    	} else {
    		Log.i("Info","Local data already exists. No need to populate database.");
    	}
    	currentDB = sql.getAllAlbums();
    	reloadListView();
    }
    
    //Create insert string function will go here.
    
    //Table population functions
    
    public void reloadListView()
    {
    	
    }
    
    public void addItemToLocalDatabase()
    {
    	String albumNameString = "Album Name"; //add reference to text in textview
    	String artistNameString = "Artist Name"; //add reference to text in textview
    	String yearString = "Year"; //add reference to text in textview
    	String albumGenreFull = "Genre"; //add reference to text in textview
    	String albumGenreId = "Genre ID"; //create function for this
    	
    	if (albumNameString == "" || artistNameString == "")
    	{
    		Toast warning = Toast.makeText(this, "You need to specify both an album name and an artist name to save data to the database.", Toast.LENGTH_SHORT);
    		warning.show();
    	} else {
    		String returnString = "INSERT INTO albums (database_id,album_name,artist_name," +
    				"album_year,genre_code) VALUES (\"NEW\",\""+albumNameString+"\",\""
    				+artistNameString+"\","+yearString+","+albumGenreId+");";
    		sql.addItemToDatabase(returnString);
    		//Add this object to the current master Cursor
    		reloadListView();
    	}
    }
    
    public void activateEditButtons()
    {
    	//This function will modify the UI to activate the Commit and Cancel buttons, as
    	//well as hide the other interface functions
    }
    
    public void deactivateEditButtons()
    {
    	//This function will modify the UI to remove the Commit and Cancel buttons, as
    	//well as hide the other interface functions.
    }
    
    public void pushNewItemsToCloud()
    {
    	Cursor newAlbums = sql.getNewAlbums();
        if (newAlbums.getCount() > 0)
        {
            if (newAlbums.moveToFirst()) 
            {
                do {
                	String thisTitle = newAlbums.getString(1);
                    String thisArtist = newAlbums.getString(2);
                    String thisDate = newAlbums.getString(3);
                    String thisGenre = newAlbums.getString(4);
                    int dateInt = Integer.parseInt(thisDate);
                    int genreInt = Integer.parseInt(thisGenre);
                    ParseObject newAlbum = new ParseObject("TestObject");
                    newAlbum.put("album_name", thisTitle);
                    newAlbum.put("artist_name", thisArtist);
                    newAlbum.put("album_year", dateInt);
                    newAlbum.put("genre_code", genreInt);
                    newAlbum.saveInBackground();
                } while (newAlbums.moveToNext());
            }
        }
            for (int x = 0; x < newAlbums.getCount(); x++)
            {
                
               
                PFObject *albumSave = [PFObject objectWithClassName:@"TestObject"];
                albumSave[@"album_name"] = thisTitle;
                albumSave[@"artist_name"] = thisArtist;
                albumSave[@"album_year"] = dateNumber;
                albumSave[@"genre_code"] = genreNumber;
                [albumSave saveInBackground];
           
    }
    
    
}
