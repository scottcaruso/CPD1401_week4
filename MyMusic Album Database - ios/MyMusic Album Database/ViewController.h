//
//  ViewController.h
//  MyMusic Album Database
//
//  Created by Scott Caruso on 1/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SqlDatabaseCreator.h"
#import <Parse/Parse.h>
#import "CustomTableView.h"

@interface ViewController : UIViewController <UITableViewDelegate,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray *masterList; //the main array that drives the data in the application
    NSMutableArray *listOfGenres;
    NSMutableArray *yearsForPicker;
    
    SqlDatabaseCreator *sql;
    
    //The various interface elements that the application is built on.
    IBOutlet UITextField *albumNameField;
    IBOutlet UITextField *artistName;
    IBOutlet UIButton *dateButton;
    IBOutlet UIButton *genreButton;
    IBOutlet UIButton *addToDatabase;
    IBOutlet UIButton *syncData;
    IBOutlet UIButton *editData;
    IBOutlet UIButton *deleteData;
    IBOutlet UIButton *commitChanges;
    IBOutlet UIButton *cancelChanges;
    IBOutlet UIPickerView *picker;
    IBOutlet UITableView *albumTable;
    IBOutlet UIImageView *picture;
    IBOutlet UISegmentedControl *filterBar;
    
    
    NSMutableArray *cloudIDs;
    
    int currentID;
    NSString *currentDBID;

    
}

-(void)retrieveAllAlbums:(NSString *) whatWeAreDoing;
-(void)fillDatabaseIfEmpty;
-(void)pushNewItemsToCloud;
-(void)addToLocalDatabase;
-(NSString *)retrieveGenreCode:(NSString *)genreName;
-(NSString *)createInsertString:(NSObject *) albumObject;

//Various interface actions.
-(IBAction)changeGenre:(id)sender;
-(IBAction)changeYear:(id)sender;
-(IBAction)syncWithServer:(id)sender;
-(IBAction)editAlbum:(id)sender;
-(IBAction)commitChanges:(id)sender;
-(IBAction)cancelChanges:(id)sender;
-(IBAction)addNewItem:(id)sender;
-(IBAction)removeItem:(id)sender;

@end
