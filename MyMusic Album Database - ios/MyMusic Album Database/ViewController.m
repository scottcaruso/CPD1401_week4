//
//  ViewController.m
//  MyMusic Album Database
//
//  Created by Scott Caruso on 1/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    masterList = [[NSMutableArray alloc] init]; //Allocate the master array that will hold all of the results that come back from the datasource.
    listOfGenres = [[NSMutableArray alloc] init]; //Allocate the genre list for decoding the genre code
    cloudIDs = [[NSMutableArray alloc] init]; // Allocate the array that will hold IDs for the cloud database
    sql = [[SqlDatabaseCreator alloc] init]; // Allocate and initialize the local database
    [sql initializeSQLiteDB]; //initialize sqlite on first boot
    [self retrieveAllAlbums:@"Startup"]; //Do the work of retrieving things from the datasource.
    [self retrieveGenres];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    albumTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    yearsForPicker = [[NSMutableArray alloc] initWithObjects:@"1960",
                      @"1961",@"1962",@"1963",@"1964",@"1965",@"1966",@"1967",@"1968",@"1969",@"1970",
                      @"1971",@"1972",@"1973",@"1974",@"1975",@"1976",@"1977",@"1978",@"1979",@"1980",
                      @"1981",@"1982",@"1983",@"1984",@"1985",@"1986",@"1987",@"1988",@"1989",@"1990",
                      @"1991",@"1992",@"1993",@"1994",@"1995",@"1996",@"1997",@"1998",@"1999",@"2000",
                      @"2001",@"2002",@"2003",@"2004",@"2005",@"2006",@"2007",@"2008",@"2009",@"2010",
                      @"2011",@"2012",@"2013",@"2014"
                      ,nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//The whatWeAreDoing string tells this function if we are checking at boot or if we are running a sync operation. Both are very similar in function, so they share the same framework.
- (void)retrieveAllAlbums:(NSString *) whatWeAreDoing
{
    PFQuery *query = [PFQuery queryWithClassName:@"TestObject"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d objects.", objects.count);
            // Put the objects into the MasterList to create the first Master List.
            for (PFObject *object in objects) {
                NSMutableDictionary *thisObject = [[NSMutableDictionary alloc] init];
                NSString *id = object.objectId;
                NSString *name = [object objectForKey:@"album_name"];
                NSString *artist = [object objectForKey:@"artist_name"];
                NSNumber *genre = [object objectForKey:@"genre_code"];
                NSNumber *date = [object objectForKey:@"album_year"];
                [thisObject setValue:name forKey:@"album"];
                [thisObject setValue:artist forKey:@"artist"];
                [thisObject setValue:genre forKey:@"genre"];
                [thisObject setValue:date forKey:@"date"];
                [thisObject setValue:id forKey:@"id"];
                [masterList addObject:thisObject];
                [cloudIDs addObject:id];
            }
            if ([whatWeAreDoing isEqualToString:@"Sync Data"])
            {
                //If we are syncing data with the cloud, the final step is to dump what is currently in memory and replace it with the cloud data. This happens AFTER additions, modifications, and deletions have occurred.
                [sql emptyDatabase];
            }
            [self fillDatabaseIfEmpty];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

//If on a check of the database, we find that it is empty, we go to the cloud and fill it up.
-(void)fillDatabaseIfEmpty
{
    NSMutableArray *currentDB = [sql returnAllRecords];
    int numberOfItems = [currentDB count];
    if (numberOfItems == 0)
    {
        int numberOfRecords = [masterList count];
        for (int x = 0; x < numberOfRecords; x++)
        {
            NSString *stringToAdd = [self createInsertString:[masterList objectAtIndex:x]];
            [sql addItemToLocalDatabase:stringToAdd];
        }
    } else {
        NSLog(@"Local data already exists. No need to populate database.");
    }
    masterList = [sql returnAllRecords];
    [albumTable reloadData];
}

//A helper function to create a string used to insert objects to the database above.
-(NSString *)createInsertString:(NSObject *) albumObject
{
    NSString *albumID = [albumObject valueForKey:@"id"];
    NSString *albumName = [albumObject valueForKey:@"album"];
    NSString *albumArtist = [albumObject valueForKey:@"artist"];
    NSNumber *albumGenre = [albumObject valueForKey:@"genre"];
    NSNumber *albumDate = [albumObject valueForKey:@"date"];
                              
    NSString *returnString = [[NSString alloc] initWithFormat:@"INSERT INTO albums (database_id,album_name,artist_name,album_year,genre_code,is_edited) VALUES(\"%@\",\"%@\",\"%@\",%@,%@,0);",albumID,albumName,albumArtist,albumDate,albumGenre];

    return returnString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [masterList count];
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",masterList);
    static NSString *cellIdentifier = @"albumCell";
    
    UITableViewCell *thisCell = (CustomTableView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (thisCell == nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSDictionary *thisAlbum = [masterList objectAtIndex:indexPath.row];
    NSLog(@"%@",thisAlbum);
    NSString *albumName = [thisAlbum objectForKey:@"album"];
    NSString *artist = [thisAlbum objectForKey:@"artist"];
    thisCell.textLabel.text = albumName;
    thisCell.detailTextLabel.text = artist;
    return thisCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentID = (indexPath.row);
    NSDictionary *selectedAlbum = [masterList objectAtIndex:indexPath.row];
    currentDBID = [selectedAlbum objectForKey:@"id"];
    albumNameField.text = [selectedAlbum objectForKey:@"album"];
    artistName.text = [selectedAlbum objectForKey:@"artist"];
    NSString *thisDate = [selectedAlbum objectForKey:@"date"];
    NSString *genreString = [self retrieveGenreName:[selectedAlbum objectForKey:@"genre"]];
    
    [genreButton setTitle:genreString forState:UIControlStateNormal];
    [dateButton setTitle:thisDate forState:UIControlStateNormal];
    
    [editData setHidden:false];
    [deleteData setHidden:false];
}

//Add a new record to the local sqlite database.
-(void)addToLocalDatabase
{
    NSString *albumNameString = albumNameField.text;
    NSString *artistNameString = artistName.text;
    NSString *yearString = dateButton.titleLabel.text;
    NSString *albumGenreFull = genreButton.titleLabel.text;
    NSString *albumGenreId = [self retrieveGenreCode:albumGenreFull];
    if ([albumNameString isEqualToString:@""] || [artistNameString isEqualToString:@""])
    {
        UIAlertView *emptyFields = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"You need to specify both an album name and an artist name to save data to the database." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyFields show];
    } else
    {
        NSString *returnString = [[NSString alloc] initWithFormat:@"INSERT INTO albums (database_id,album_name,artist_name,album_year,genre_code) VALUES(\"NEW\",\"%@\",\"%@\",%i,%i);",albumNameString,artistNameString,[yearString intValue],[albumGenreId intValue]];
        [sql addItemToLocalDatabase:returnString];
        NSMutableDictionary *thisObject = [[NSMutableDictionary alloc] init];
        [thisObject setValue:albumNameString forKey:@"album"];
        [thisObject setValue:artistNameString forKey:@"artist"];
        [thisObject setValue:albumGenreId forKey:@"genre"];
        [thisObject setValue:yearString forKey:@"date"];
        [masterList addObject:thisObject];
        [albumTable reloadData];
    }
}

//Prepare the interface and pass data around for adding a new item.
-(IBAction)addNewItem:(id)sender
{
    [self activateEditFields];
    [self deactivateActionButtons];
    albumNameField.text = @"";
    artistName.text = @"";
    [dateButton setTitle:@"2000" forState:UIControlStateNormal];
    [genreButton setTitle:@"Modern Rock" forState:UIControlStateNormal];
    [commitChanges setTag:1];
}

//Prepare the interface and confirm that the user actually wants to remove an item from the database.
-(IBAction)removeItem:(id)sender
{
    [commitChanges setTag:2];
    UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to remove this album from your local database? This cannot be undone and will also cause the album to be removed from the main database upon the next sync!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [confirmation show];
}

//Prepare the spinner view to select a genre.
-(IBAction)changeGenre:(id)sender
{
    [picker setTag:1];
    [picker setHidden:false];
    [picture setHidden:true];
    [picker reloadAllComponents];
}

//Prepare the spinner view to select a year.
-(IBAction)changeYear:(id)sender
{
    [picker setTag:0];
    [picker setHidden:false];
    [picture setHidden: true];
    [picker reloadAllComponents];
}

-(IBAction)syncWithServer:(id)sender
{
    //Check to see if there are any new items in the local database and push those
    [self pushNewItemsToCloud];
    
    //Check to see if there are any items in the local database that have been edited and push those changes
    [self pushEditedItemsToCloud];
    
    ///Check to see if anything has been deleted from the local database, and delete it from the remote database
    [self deleteItemsInCloud];
    
    //Sync remote database back down
    [masterList removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"deletedItems"];
    [defaults synchronize];
    [self retrieveAllAlbums:@"Sync Data"];
}


//Activate the "edit" interface - disable certain actions and activate the database fields for editing.
-(IBAction)editAlbum:(id)sender
{
    [commitChanges setTag:0];
    [self activateEditFields];
    [self deactivateActionButtons];
}

//Take no action and close down editing functions.
-(IBAction)cancelChanges:(id)sender
{
    [self deactivateEditFields];
    [self activateActionButtons];
    [picker setHidden:true];
}

//Calls an AlertView to confirm that the user wants to commit changes that he is making
-(IBAction)commitChanges:(id)sender
{
    UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to commit these changes to your local database? This cannot be undone!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [confirmation show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Are you sure?"])
    {
        // buttonIndex 1 is "OK" on the alert popups
        if (buttonIndex == 1)
        {
            NSString *newTitle = albumNameField.text;
            NSString *newArtist = artistName.text;
            NSString *newYear = dateButton.titleLabel.text;
            NSString *newGenre = genreButton.titleLabel.text;
            NSString *genreID = [self retrieveGenreCode:newGenre];
            NSMutableDictionary *updateItem = [[NSMutableDictionary alloc] init];
            [updateItem setValue:newTitle forKey:@"title"];
            [updateItem setValue:newArtist forKey:@"artist"];
            [updateItem setValue:newYear forKey:@"date"];
            [updateItem setValue:genreID forKey:@"genre"];
            
            //commitChanges.tag 0 = modifiying an existing record
            //commitChanges.tag 1 = adding a new record
            //commitChanges.tag 2 = deleting a record
            
            if (commitChanges.tag == 0)
            {
                [sql modifyItemInDatabase:currentDBID newData:updateItem];
                masterList = [sql returnAllRecords];
            } else  if (commitChanges.tag == 1)
            {
                [self addToLocalDatabase];
                masterList = [sql returnAllRecords];
            } else if (commitChanges.tag == 2)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *deletedItems = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"deletedItems"]];
                NSDictionary *dictionary = [masterList objectAtIndex:(currentID)];
                [deletedItems addObject:[dictionary objectForKey:@"id"]];
                [defaults setObject:deletedItems forKey:@"deletedItems"];
                [defaults synchronize];
                [sql removeItemInDatabase:currentDBID];
                masterList = [sql returnAllRecords]; //update the Master List based on the deletion.
                [sql emptyDatabase]; //empty the DB to re-key the values
                [self fillDatabaseIfEmpty]; //repopulate the database with the MasterList
                albumNameField.text = @"";
                artistName.text = @"";
                [dateButton setTitle:@"" forState:UIControlStateNormal];
                [genreButton setTitle:@"" forState:UIControlStateNormal];
                filterBar.selectedSegmentIndex = 0;
            }
            [self deactivateEditFields];
            [self activateActionButtons];
            [albumTable reloadData];
        }
    }
    
}

//Prepares new items (those that the DB doesn't know about) for moving up to the cloud.
-(void)pushNewItemsToCloud
{
    NSMutableArray *newAlbums = [sql returnNewRecords];
    if ([newAlbums count] > 0)
    {
        for (int x = 0; x < [newAlbums count]; x++)
        {
            NSDictionary *thisAlbum = [newAlbums objectAtIndex:x];
            NSString *thisTitle = [thisAlbum objectForKey:@"album"];
            NSString *thisArtist = [thisAlbum objectForKey:@"artist"];
            NSString *thisDate = [thisAlbum objectForKey:@"date"];
            NSString *thisGenre = [thisAlbum objectForKey:@"genre"];
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *dateNumber = [nf numberFromString:thisDate];
            NSNumber *genreNumber = [nf numberFromString:thisGenre];
            
            PFObject *albumSave = [PFObject objectWithClassName:@"TestObject"];
            albumSave[@"album_name"] = thisTitle;
            albumSave[@"artist_name"] = thisArtist;
            albumSave[@"album_year"] = dateNumber;
            albumSave[@"genre_code"] = genreNumber;
            [albumSave saveInBackground];
        }
    }
}

//Prepares edited items for moving up to the cloud.
-(void)pushEditedItemsToCloud
{
    NSMutableArray *newAlbums = [sql returnEditedRecords];
    if ([newAlbums count] > 0)
    {
        for (int x = 0; x < [newAlbums count]; x++)
        {
            NSDictionary *thisAlbum = [newAlbums objectAtIndex:x];
            NSString *thisID = [thisAlbum objectForKey:@"id"];
            NSString *thisTitle = [thisAlbum objectForKey:@"album"];
            NSString *thisArtist = [thisAlbum objectForKey:@"artist"];
            NSString *thisDate = [thisAlbum objectForKey:@"date"];
            NSString *thisGenre = [thisAlbum objectForKey:@"genre"];
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *dateNumber = [nf numberFromString:thisDate];
            NSNumber *genreNumber = [nf numberFromString:thisGenre];
            
            PFQuery *query = [PFQuery queryWithClassName:@"TestObject"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:thisID block:^(PFObject *albumSave, NSError *error) {
                
                albumSave[@"album_name"] = thisTitle;
                albumSave[@"artist_name"] = thisArtist;
                albumSave[@"album_year"] = dateNumber;
                albumSave[@"genre_code"] = genreNumber;
                [albumSave saveInBackground];
            }];
        }
    }
}

//Prepares to delete items from the cloud
-(void)deleteItemsInCloud
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultArray = [[NSArray alloc] initWithArray:[defaults objectForKey:@"deletedItems"]];
    
    for (int x = 0; x < [defaultArray count]; x ++)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"TestObject"];
        NSString *thisID = [defaultArray objectAtIndex:x];
        [query getObjectInBackgroundWithId:thisID block:^(PFObject *thisAlbum, NSError *error) {
            [thisAlbum deleteInBackground];
        }];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//PickerView management
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (picker.tag == 0)
    {
        return [yearsForPicker count];
    } else if (picker.tag == 1)
    {
        return [listOfGenres count];
    } else
    {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (picker.tag == 0)
    {
        return [yearsForPicker objectAtIndex:row];
    } else if (picker.tag == 1)
    {
        NSDictionary *thisGenre = [listOfGenres objectAtIndex:row];
        return [thisGenre objectForKey:@"genre"];
    } else
    {
        return @"Placeholder";
    }
    
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (picker.tag == 0)
    {
        [dateButton setTitle:[yearsForPicker objectAtIndex:row] forState:UIControlStateNormal];
        [picker setHidden:true];
        [picture setHidden:false];
    } else if (picker.tag == 1)
    {
        NSDictionary *thisGenre = [listOfGenres objectAtIndex:row];
        [genreButton setTitle:[thisGenre objectForKey:@"genre"] forState:UIControlStateNormal];
        [picker setHidden:true];
        [picture setHidden:false];
    }
}

-(NSString *)retrieveGenreName:(NSString *)genreCode
{
    int genreInt = [genreCode intValue];
    NSDictionary *thisGenre = [listOfGenres objectAtIndex:genreInt-1];
    NSString *genreString = [thisGenre objectForKey:@"genre"];
    return genreString;
}

-(NSString *)retrieveGenreCode:(NSString *)genreName
{
    for (int x = 0; x < [listOfGenres count]; x++)
    {
        NSDictionary *thisGenre = [listOfGenres objectAtIndex:x];
        NSString *currentGenre = [thisGenre objectForKey:@"genre"];
        if ([currentGenre isEqualToString:genreName])
        {
            NSString *genreID = [thisGenre objectForKey:@"id"];
            return genreID;
        }
    }
    return @"";
}

-(IBAction)segmentClicked:(id)sender
{
    switch (filterBar.selectedSegmentIndex) {
        case 0:
            [self retrieveAllAlbums:@"Filtering"];
            break;
            
        case 1:
            masterList = [sql returnfilteredresults:1];
            [albumTable reloadData];
            break;
            
        case 2:
            masterList = [sql returnfilteredresults:2];
            [albumTable reloadData];
            break;
            
        case 3:
            masterList = [sql returnfilteredresults:3];
            [albumTable reloadData];
            break;
            
        case 4:
             masterList = [sql returnfilteredresults:4];
            [albumTable reloadData];
            break;
            
        case 5:
            masterList = [sql returnfilteredresults:5];
            [albumTable reloadData];
            break;
            
        case 6:
            masterList = [sql returnfilteredresults:6];
            [albumTable reloadData];
            break;
            
        case 7:
            masterList = [sql returnfilteredresults:7];
            [albumTable reloadData];
            break;
            
        case 8:
            masterList = [sql returnfilteredresults:8];
            [albumTable reloadData];
            break;
            
        default:
            break;
    }
}


//This helper function retrieves the list of Music Genres from the cloud database.
-(void)retrieveGenres
{
    PFQuery *query = [PFQuery queryWithClassName:@"MusicGenres"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSMutableDictionary *thisObject = [[NSMutableDictionary alloc] init];
                NSNumber *id = [object objectForKey:@"genre_code"];
                NSString *genreName = [object objectForKey:@"genre_name"];
                [thisObject setValue:id forKey:@"id"];
                [thisObject setValue:genreName forKey:@"genre"];
                [listOfGenres addObject:thisObject];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


//The following are a series of heper functions that simply hide/unhide large blocks for interface elements based on what has been selected.

-(void)activateEditFields
{
    [albumNameField setTextColor:[UIColor blackColor]];
    [albumNameField setEnabled:true];
    [artistName setTextColor:[UIColor blackColor]];
    [artistName setEnabled:true];
    [genreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [genreButton setEnabled:true];
    [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dateButton setEnabled:true];
}

-(void)deactivateActionButtons
{
    [addToDatabase setHidden:true];
    [editData setHidden:true];
    [deleteData setHidden:true];
    [syncData setHidden:true];
    [commitChanges setHidden:false];
    [cancelChanges setHidden:false];
    [albumTable setUserInteractionEnabled:false];
}

-(void)deactivateEditFields
{
    [albumNameField setTextColor:[UIColor lightGrayColor]];
    [albumNameField setEnabled:false];
    [artistName setTextColor:[UIColor lightGrayColor]];
    [artistName setEnabled:false];
    [genreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [genreButton setEnabled:false];
    [dateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [dateButton setEnabled:false];
}

-(void)activateActionButtons
{
    [addToDatabase setHidden:false];
    [editData setHidden:false];
    [deleteData setHidden:false];
    [syncData setHidden:false];
    [commitChanges setHidden:true];
    [cancelChanges setHidden:true];
    [albumTable setUserInteractionEnabled:true];
}

@end
