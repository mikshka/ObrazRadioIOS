//
//  DBManager.h
//  ObrazRadioIOS
//
//  Created by Михаил Коршунов on 12.08.16.
//  Copyright © 2016 Михаил Коршунов. All rights reserved.
//

#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-saveData:(NSArray*)program;
-(NSMutableArray*) getTodayProgram;
-(BOOL)clearDB;
-(NSDate*)getProgramDate;

@end