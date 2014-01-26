//
//  SqlDatabaseCreator.h
//  MyMusic Album Database
//
//  Created by Scott Caruso on 1/21/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SqlDatabaseCreator : NSObject
{
    NSString *dbPath;
    sqlite3 *dbContext;
    NSString *databaseID;
    NSMutableArray *arrayOfRecords;
    NSMutableArray *arrayOfRoles;
    NSArray *dirpaths;
    NSString *documentsDirectory;
    NSString *dbName;
    const char *database;
}

-(NSMutableArray *)returnAllRecords;
-(NSMutableArray *)returnNewRecords;
-(NSMutableArray *)returnEditedRecords;
-(NSMutableArray *)returnfilteredresults:(int)filterParam;

-(void)addItemToLocalDatabase:(NSString *) sqlString;
-(void)initializeSQLiteDB;
-(void)emptyDatabase;
-(void)modifyItemInDatabase:(NSString *)dbID newData:(NSMutableDictionary*)data;
-(void)removeItemInDatabase:(NSString *)dbID;
-(void)createGenresTable;


@end
