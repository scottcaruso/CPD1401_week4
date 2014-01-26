//
//  SqlDatabaseCreator.m
//  MyMusic Album Database
//
//  Created by Scott Caruso on 1/21/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "SqlDatabaseCreator.h"
#import <sqlite3.h>

@implementation SqlDatabaseCreator

const char *ifEmpty = "CREATE TABLE IF NOT EXISTS albums (id INTEGER PRIMARY KEY, database_id varchar(50), album_name varchar(50), artist_name varchar(50), album_year INTEGER, genre_code INTEGER, is_edited INTEGER);";
const char *genres = "CREATE TABLE IF NOT EXISTS genres (id INTEGER PRIMARY KEY, genre_name varchar(50));";
const char *selectAllRecords = "SELECT * FROM albums;";

-(id)init
{
    return self;
}

//REMINDER: ANYWHERE THAT THIS GETS USED MUST END WITH A sqlite3_close(dbContext) CALL
-(void)initializeSQLiteDB
{
    dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE);
    if (dirpaths != nil)
    {
        documentsDirectory = [dirpaths objectAtIndex:0];
        dbName = @"albums.sqlite";
        dbPath = [documentsDirectory stringByAppendingPathComponent:dbName];
        database = [dbPath UTF8String];
        
        if (sqlite3_open(database, &dbContext) == SQLITE_OK)
        {
            char *error;
            if (sqlite3_exec(dbContext,ifEmpty,NULL,NULL,&error) != SQLITE_OK)
            {
                NSLog(@"There was an error intiializing the database: %i",sqlite3_exec(dbContext,ifEmpty,NULL,NULL,&error));
                //Error out
            }
        }
    }
}

//Return all of the records in the local sqlite database for manipulation.
-(NSMutableArray *)returnAllRecords
{
    [self initializeSQLiteDB];
    sqlite3_stmt *compiledSelectStatement;
    if (sqlite3_prepare_v2(dbContext, selectAllRecords, -1, &compiledSelectStatement, NULL) == SQLITE_OK)
    {
        arrayOfRecords = [[NSMutableArray alloc] init];
        while (sqlite3_step(compiledSelectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *thisAlbum = [[NSMutableDictionary alloc] init];
            NSString *dbID =[[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,1)];
            NSString *albumName =[[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,2)];
            NSString *artist =[[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,3)];
            NSString *date =[[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,4)];
            NSString *genre =[[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,5)];
            
            [thisAlbum setValue:dbID forKey:@"id"];
            [thisAlbum setValue:albumName forKey:@"album"];
            [thisAlbum setValue:artist forKey:@"artist"];
            [thisAlbum setValue:date forKey:@"date"];
            [thisAlbum setValue:genre forKey:@"genre"];

            [arrayOfRecords addObject:thisAlbum];
        }
    }
    return arrayOfRecords;
    
    sqlite3_close(dbContext);
}

//Take data from the ViewController, format it, and add it to the local sqlite database.
-(void)addItemToLocalDatabase:(NSString *) sqlString
{
    [self initializeSQLiteDB];
    if (sqlite3_open(database, &dbContext) == SQLITE_OK)
    {
        const char *addItem = [sqlString UTF8String];
        sqlite3_stmt *compiledInsertStatementOne;
        NSLog(@"%s",addItem);
        if (sqlite3_prepare_v2(dbContext, addItem, -1, &compiledInsertStatementOne, NULL) == SQLITE_OK)
        {
            NSLog(@"%i",sqlite3_step(compiledInsertStatementOne));
            if (sqlite3_step(compiledInsertStatementOne) == SQLITE_DONE)
            {
                NSLog(@"Adding item to local database.");
                sqlite3_finalize(compiledInsertStatementOne);
            }
        }
        
        sqlite3_close(dbContext);
    }
}

//Return only those records flagged as NEW to the ViewController
-(NSMutableArray *)returnNewRecords
{
    arrayOfRecords = [[NSMutableArray alloc] init];
    NSString *returnString = @"SELECT * FROM albums WHERE database_id=\"NEW\";";
    const char *selectString = [returnString UTF8String];
    sqlite3_stmt *compiledSelectStatement;
    if (sqlite3_prepare_v2(dbContext, selectString, -1, &compiledSelectStatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(compiledSelectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *thisAlbum = [[NSMutableDictionary alloc] init];
            NSString *albumName = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,2)];
            NSString *artist = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,3)];
            NSString *date = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,4)];
            NSString *genre = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,5)];
            [thisAlbum setValue:albumName forKey:@"album"];
            [thisAlbum setValue:artist forKey:@"artist"];
            [thisAlbum setValue:date forKey:@"date"];
            [thisAlbum setValue:genre forKey:@"genre"];
            [arrayOfRecords addObject:thisAlbum];
        }
    }
    return arrayOfRecords;
    
    sqlite3_close(dbContext);
}

//Return only those albums marked as "edited" to the ViewController.
-(NSMutableArray *)returnEditedRecords
{
    arrayOfRecords = [[NSMutableArray alloc] init];
    NSString *returnString = @"SELECT * FROM albums WHERE is_edited=1;";
    const char *selectString = [returnString UTF8String];
    sqlite3_stmt *compiledSelectStatement;
    if (sqlite3_prepare_v2(dbContext, selectString, -1, &compiledSelectStatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(compiledSelectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *thisAlbum = [[NSMutableDictionary alloc] init];
            NSString *dbID = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,1)];
            NSString *albumName = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,2)];
            NSString *artist = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,3)];
            NSString *date = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,4)];
            NSString *genre = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,5)];
            [thisAlbum setValue:dbID forKey:@"id"];
            [thisAlbum setValue:albumName forKey:@"album"];
            [thisAlbum setValue:artist forKey:@"artist"];
            [thisAlbum setValue:date forKey:@"date"];
            [thisAlbum setValue:genre forKey:@"genre"];
            [arrayOfRecords addObject:thisAlbum];
        }
    }
    return arrayOfRecords;
    
    sqlite3_close(dbContext);
}

//Function to completely empty the database to prepare for a db sync.
-(void)emptyDatabase
{
    NSString *truncateString = @"DELETE FROM albums;VACUUM;";
    [self initializeSQLiteDB];
    if (sqlite3_open(database, &dbContext) == SQLITE_OK)
    {
        const char *emptyDB = [truncateString UTF8String];
        sqlite3_stmt *compiledDeleteStatement;
        NSLog(@"%d",sqlite3_prepare_v2(dbContext, emptyDB, -1, &compiledDeleteStatement, NULL));
        if (sqlite3_prepare_v2(dbContext, emptyDB, -1, &compiledDeleteStatement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(compiledDeleteStatement) == SQLITE_DONE)
            {
                sqlite3_finalize(compiledDeleteStatement);
            }
        }
        sqlite3_close(dbContext);
    }
}

//Modify an existing item in the sql database based on the data passed in by the ViewController.
-(void)modifyItemInDatabase:(NSString *)dbID newData:(NSMutableDictionary*)data
{
    [self initializeSQLiteDB];
    NSString *newTitle = [data objectForKey:@"title"];
    NSString *newArtist = [data objectForKey:@"artist"];
    NSString *newYear = [data objectForKey:@"date"];
    NSString *newGenre = [data objectForKey:@"genre"];
    NSString *sqlString = [[NSString alloc] initWithFormat:@"UPDATE albums SET album_name=\"%@\",artist_name=\"%@\",album_year=%@,genre_code=%@,is_edited=1 WHERE database_id=\"%@\";",newTitle,newArtist,newYear,newGenre,dbID];
    if (sqlite3_open(database, &dbContext) == SQLITE_OK)
    {
        const char *modifyItem = [sqlString UTF8String];
        sqlite3_stmt *compiledModifyStatement;
        NSLog(@"%s",modifyItem);
        if (sqlite3_prepare_v2(dbContext, modifyItem, -1, &compiledModifyStatement, NULL) == SQLITE_OK)
        {
            NSLog(@"%i",sqlite3_step(compiledModifyStatement));
            if (sqlite3_step(compiledModifyStatement) == SQLITE_DONE)
            {
                sqlite3_finalize(compiledModifyStatement);
            }
        }
        
        sqlite3_close(dbContext);
    }
}

//Remove an item from the local sqlite database based on an id passed in by the ViewController.
-(void)removeItemInDatabase:(NSString *)dbID
{
    [self initializeSQLiteDB];
    NSString *sqlString = [[NSString alloc] initWithFormat:@"DELETE FROM albums WHERE database_id=\"%@\";",dbID];
    if (sqlite3_open(database, &dbContext) == SQLITE_OK)
    {
        const char *deleteItem = [sqlString UTF8String];
        sqlite3_stmt *compiledDeleteStatement;
        NSLog(@"%s",deleteItem);
        if (sqlite3_prepare_v2(dbContext, deleteItem, -1, &compiledDeleteStatement, NULL) == SQLITE_OK)
        {
            NSLog(@"%i",sqlite3_step(compiledDeleteStatement));
            if (sqlite3_step(compiledDeleteStatement) == SQLITE_DONE)
            {
                sqlite3_finalize(compiledDeleteStatement);
            }
        }
        
        sqlite3_close(dbContext);
    }
}

//Return a subset of the total records based on which category the user wants to filter on.
-(NSMutableArray *)returnfilteredresults:(int)filterParam
{
    arrayOfRecords = [[NSMutableArray alloc] init];
    NSString *returnString = [[NSString alloc] initWithFormat:@"SELECT * FROM albums WHERE genre_code=%i;",filterParam];
    const char *selectString = [returnString UTF8String];
    sqlite3_stmt *compiledSelectStatement;
    if (sqlite3_prepare_v2(dbContext, selectString, -1, &compiledSelectStatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(compiledSelectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *thisAlbum = [[NSMutableDictionary alloc] init];
            NSString *dbID = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,1)];
            NSString *albumName = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,2)];
            NSString *artist = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,3)];
            NSString *date = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,4)];
            NSString *genre = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(compiledSelectStatement,5)];
            [thisAlbum setValue:dbID forKey:@"id"];
            [thisAlbum setValue:albumName forKey:@"album"];
            [thisAlbum setValue:artist forKey:@"artist"];
            [thisAlbum setValue:date forKey:@"date"];
            [thisAlbum setValue:genre forKey:@"genre"];

            [arrayOfRecords addObject:thisAlbum];
        }
    }
    return arrayOfRecords;
    
    sqlite3_close(dbContext);
}


//Not yet used, but creates an sql version of the genres table.
-(void)createGenresTable
{
    [self initializeSQLiteDB];
    if (sqlite3_open(database, &dbContext) == SQLITE_OK)
    {
        sqlite3_stmt *compiledInsertStatement;
        if (sqlite3_prepare_v2(dbContext, genres, -1, &compiledInsertStatement, NULL) == SQLITE_OK)
        {
            NSLog(@"%i",sqlite3_step(compiledInsertStatement));
            if (sqlite3_step(compiledInsertStatement) == SQLITE_DONE)
            {
                sqlite3_finalize(compiledInsertStatement);
            }
        }
        
        sqlite3_close(dbContext);
    }
}


@end
