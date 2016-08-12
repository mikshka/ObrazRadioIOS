//
//  Program.h
//  ObrazRadioIOS
//
//  Created by Михаил Коршунов on 12.08.16.
//  Copyright © 2016 Михаил Коршунов. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Program : NSObject

@property (strong, nonatomic) NSDate *programDate;
@property (nonatomic, assign) int hours;
@property (nonatomic, assign) int minutes;
@property (strong, nonatomic) NSString *programName;

@end