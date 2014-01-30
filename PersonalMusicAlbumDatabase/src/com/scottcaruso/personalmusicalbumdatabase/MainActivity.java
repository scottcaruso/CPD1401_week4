package com.scottcaruso.personalmusicalbumdatabase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.Parse;
import com.parse.ParseAnalytics;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

public class MainActivity extends Activity {
	
	public static ArrayList<HashMap<String,String>> masterArray;
	public static ArrayList<String> listOfGenres;
	public static ArrayList<String> cloudIDs;
	public static Cursor currentDB;
	public static SQLiteHelper sql;
	public static ListView listView;
	public static TextView albumNameField;
	public static TextView artistNameField;
	public static Button yearButton;
	public static Button genreButton;
	public static String currentID;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        masterArray = new ArrayList<HashMap<String,String>>();
        cloudIDs = new ArrayList<String>();
        listOfGenres = new ArrayList<String>();
        sql = new SQLiteHelper(this);
        sql.createDB();
        Parse.initialize(this, "GSJTIddEqF4RT6PmWi6VgKx63b5DWCDVDNRZyR9m", "O17apZByYdFumITsEpo8ndtjfFQ7MIJ3C7U0SYxt");
        retrieveAllAlbums("Startup");
        retrieveAllGenres();
        
        setContentView(R.layout.activity_main);
        //Assign UI elements
        albumNameField = (TextView) findViewById(R.id.albumfield);
        artistNameField = (TextView) findViewById(R.id.artistfield);
        yearButton = (Button) findViewById(R.id.yearbutton);
        genreButton = (Button) findViewById(R.id.genrebutton);
        
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
	               // Put the objects into the MasterList to create the first Master List.
	               for (ParseObject album : albums) {
		               HashMap<String,String> thisAlbum = new HashMap<String,String>();
		               thisAlbum.put("db_id", album.getObjectId());
		               thisAlbum.put("albumName", album.getString("album_name"));
		               thisAlbum.put("artistName", album.getString("artist_name"));
		               thisAlbum.put("date", String.valueOf(album.getInt("album_year")));
		               thisAlbum.put("genre", String.valueOf(album.getInt("genre_code")));
		               masterArray.add(thisAlbum);
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
   
   public void retrieveAllGenres()
   {
	   ParseQuery<ParseObject> query = ParseQuery.getQuery("MusicGenres");
	   query.findInBackground(new FindCallback<ParseObject>() {
		   
		   @Override
	       public void done(List<ParseObject> genres, ParseException e) {
	           if (e == null) {
	               // Put the objects into the MasterList to create the first Master List.
	               for (ParseObject genre : genres) {
	            	   listOfGenres.add(genre.getString("genre_name"));
	               }
	           } else {
	               Log.d("score", "Error: " + e.getMessage());
	           }
	       }	
	   });
   }
	               
    public void fillDatabaseIfEmpty()
    {
    	currentDB = sql.getAllAlbums();
    	int numberOfItems = currentDB.getCount();
    	if (numberOfItems == 0)
    	{
    		int numberOfRecords = masterArray.size();
            for (int x = 0; x < numberOfRecords; x++)
            {
            
                String stringToAdd = createInsertString(masterArray.get(x));
                sql.addItemToLocalDatabase(stringToAdd);
            }
    	} else {
    		Log.i("Info","Local data already exists. No need to populate database.");
    	}
    	currentDB = sql.getAllAlbums();
    	reloadListView(currentDB);
    }
    
    public String createInsertString(HashMap<String,String> object)
    {
    	String albumID = object.get("db_id");
    	String albumName = object.get("albumName");
    	String albumArtist = object.get("artistName");
    	String albumGenre = object.get("genre");
    	String albumDate = object.get("date");
    	
    	String sqlString = "INSERT INTO albums (database_id,album_name,artist_name,album_year," +
    			"genre_code,is_edited) VALUES (\""+albumID+"\",\""+albumName+"\"," +
    					"\""+albumArtist+"\",\""+albumDate+"\"" +
    							","+albumGenre+",0);";
    	return sqlString;
    }
    
    //Table population functions
    
	public void reloadListView(Cursor thisCursor)
    {
    	ArrayList<String> arrayOfAlbums = new ArrayList<String>();
    	ArrayList<String> arrayOfArtists = new ArrayList<String>();
        if (thisCursor.moveToFirst()) {
            do {
                arrayOfAlbums.add(thisCursor.getString(2));
                arrayOfArtists.add(thisCursor.getString(3));
            } while (thisCursor.moveToNext());
        }
        
        List<Map<String, String>> data = new ArrayList<Map<String, String>>();
        for (int x = 0; x < arrayOfAlbums.size(); x++) 
        {
            Map<String, String> dataItem = new HashMap<String, String>(2);
            dataItem.put("album", arrayOfAlbums.get(x));
            dataItem.put("artist", arrayOfArtists.get(x));
            data.add(dataItem);
        }
        
        SimpleAdapter adapter = new SimpleAdapter(this, data,
                                                  android.R.layout.simple_list_item_2,
                                                  new String[] {"album", "artist"},
                                                  new int[] {android.R.id.text1,
                                                             android.R.id.text2});
        
        listView = (ListView) findViewById(R.id.listView1);    	
    	listView.setAdapter(adapter);
    	listView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View view, int item,
					long id) {
				
				Log.i("Info","We clicked " + String.valueOf(item));
				updateUIElements(currentDB, item);
			}
		});
    	
    }
	
	public void updateUIElements(Cursor cursor, int row)
	{
        if (cursor.moveToPosition(row)) {
        	String albumName = cursor.getString(2);
        	String artistName = cursor.getString(3);
        	String yearValue = cursor.getString(4);
        	String genreValue = cursor.getString(5);
        	String genreNameValue = retrieveGenreName(genreValue);
        	albumNameField.setText(albumName);
        	artistNameField.setText(artistName);
        	yearButton.setText(yearValue);
        	genreButton.setText(genreNameValue);
        	currentID = cursor.getString(1);
        }
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
    		sql.addItemToLocalDatabase(returnString);
    		
    		//Add this object to the current master Cursor
    		Cursor newList = sql.getAllAlbums();
    		reloadListView(newList);
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
    }
    
    public void pushEditedItemsToCloud()
    {
    	Cursor newAlbums = sql.getEditedItems();
        if (newAlbums.getCount() > 0)
        {
            if (newAlbums.moveToFirst()) 
            {
                do {
                	String thisID = newAlbums.getString(0);
                	final String thisTitle = newAlbums.getString(1);
                    final String thisArtist = newAlbums.getString(2);
                    String thisDate = newAlbums.getString(3);
                    String thisGenre = newAlbums.getString(4);
                    final int dateInt = Integer.parseInt(thisDate);
                    final int genreInt = Integer.parseInt(thisGenre);
                    ParseQuery<ParseObject> query = ParseQuery.getQuery("Test Object");
                    
                    query.getInBackground(thisID, new GetCallback<ParseObject>() {
                    	public void done(ParseObject thisAlbum, ParseException e) {
                    		if (e == null) {
                       
                            thisAlbum.put("album_name", thisTitle);
                            thisAlbum.put("artist_name", thisArtist);
                            thisAlbum.put("album_year", dateInt);
                            thisAlbum.put("genre_code", genreInt);
                            thisAlbum.saveInBackground();
                    		}
                    	}
                    });
                } while (newAlbums.moveToNext());
            }
        }  
    }
    
    public void deleteItemsInCloud(Context context)
    {
        SharedPreferences preferences = context.getSharedPreferences("Delete", Context.MODE_PRIVATE);
        String toDelete = preferences.getString("items",null);
        if (!toDelete.isEmpty())
        {
        	if (!toDelete.contains(","))
        	{
        		
        	} else
        	{
        		int stringLength = toDelete.length();
        		int numberOfCommas = 1;
        		int locationOfPreviousComma = 0;
        		String comma = ",";
        		for (int x = 0; x <= stringLength; x++)
        		{
        			char thisChar = toDelete.charAt(x);
        			if (thisChar == comma.charAt(0))
        			{
        				String id = toDelete.substring(locationOfPreviousComma, x+1);
        				ParseQuery<ParseObject> query = ParseQuery.getQuery("TestObject");
        				query.getInBackground(id, new GetCallback<ParseObject>() {
                        	public void done(ParseObject thisAlbum, ParseException e) {
                        		if (e == null) {
                                thisAlbum.deleteInBackground();
                        		}
                        	}
                        });
        				locationOfPreviousComma = x+1;
        				numberOfCommas++;
        			}
        		}
        	}
        }
    }
    
    public String retrieveGenreName(String genreCode)
    {
    	int genreInt = Integer.valueOf(genreCode);
    	String thisGenre = listOfGenres.get(genreInt-1);
    	return thisGenre;
    }
    
    public String retrieveGenreCode(String genreName)
    {
        for (int x = 0; x < listOfGenres.size(); x++)
        {
            String thisGenre = listOfGenres.get(x);
            if (genreName == thisGenre)
            {
            	String genreID = String.valueOf(x+1);
            	return genreID;
            }
        }
        return "";
    }
    
  /*--Init
    int myvar = 12;


    //--SAVE Data
    SharedPreferences preferences = context.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);  
    SharedPreferences.Editor editor = preferences.edit();
    editor.putInt("var1", myvar);
    editor.commit();*/
    
}
