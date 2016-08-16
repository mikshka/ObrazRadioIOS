//
//  DBManager.m
//  ObrazRadioIOS
//
//  Created by Михаил Коршунов on 12.08.16.
//  Copyright © 2016 Михаил Коршунов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "Program.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"radioobraz.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists schedule (_id integer primary key autoincrement, sc_date date, programName text, programTime text);";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-saveData:(NSArray*)program;
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        for(int i = 0; i < [program count]; i++) {
            Program *p = [program objectAtIndex:i];
            //NSString *sqlInsert = @"insert into myTable (_id, name, area, title, description, url) VALUES (?, ?, ?, ?, ?, ?)";
            NSString *insertSQL = @"INSERT INTO schedule(sc_date, programName, programTime) VALUES (date('now'), ?, ?)";
            
            //NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO schedule(sc_date, programName, programTime) VALUES (date('now'), \"%@\", \"%@\")", [p programName], [p programTime]];
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            sqlite3_bind_text(statement, 0, [p.programName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 1, [p.programTime UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to add record pName=%@ pTime%@",[p programName], [p programTime]);
            }
        }
        
    } else {
        sqlite3_close(database);
    }
    return NO;
}

- (NSMutableArray*) getTodayProgram
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT sc_date, programName, programTime FROM schedule where sc_date = date('now')";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSDate* today = [NSDate date];
                
                NSMutableArray *programs = [NSMutableArray array];
                
                Program *curProgram = [[Program alloc] init];
                curProgram.programDate = today;
                curProgram.programName = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                curProgram.programTime = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                
                
                [programs addObject:curProgram];
                
            }
            return resultArray;
            
        }
    } else {
        sqlite3_close(database);
    }
    return nil;
}
-(BOOL)clearDB;
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *deleteSQL = @"DELETE FROM schedule";
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        } else {
            return NO;
        }
        
    } else {
        sqlite3_close(database);
    }
    return NO;
}
-(NSDate*)getProgramDate;
{
    NSString *querySQL = @"SELECT strftime('%Y-%m-%d', sc_date) FROM schedule where sc_date = date('now')";
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        int sqlite_code = sqlite3_step(statement);
        if (sqlite_code == SQLITE_DONE)
        {
            //NSDate* today = [NSDate date];
            
            NSString *programDateText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyy-MM-dd"];
            NSDate *programDate = [dateFormatter dateFromString:programDateText];
            return programDate;
        }
    } else {
        sqlite3_close(database);
    }
    return nil;
}

@end
