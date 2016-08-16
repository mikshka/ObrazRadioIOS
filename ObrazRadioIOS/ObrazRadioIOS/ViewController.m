//
//  ViewController.m
//  ObrazRadioIOS
//
//  Created by Михаил Коршунов on 01.08.16.
//  Copyright © 2016 Михаил Коршунов. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVAudioPlayer.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioToolbox/AudioFileStream.h>
#include <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "Program.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isPlaying = NO;
    
    NSURL *url = [NSURL URLWithString:@"http://213.177.106.78:8002"];
    NSURL *scheduleUrl = [NSURL URLWithString:@"http://obrazschedule.ru/schedule/?action=get_schedule"];
    self.programs = [NSMutableArray array];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem: self.playerItem];
    self.player = [AVPlayer playerWithURL:url];
    
    [self loadTodayProgram];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play
{
    if (_isPlaying == NO) {
    
        [self.player play];
        _isPlaying = YES;
        
    } else {
        
        [self.player pause];
        _isPlaying = NO;
    }
}

+ (NSMutableDictionary *)jsonRequestWithURL:(NSString *)url
{
    NSError *error;
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
    
    NSMutableDictionary *allElements = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    return allElements;
}

- (void)simpleJsonParsing
{
    //-- Make URL request with server
    NSHTTPURLResponse *response = nil;
    NSString *jsonUrlString = [NSString stringWithFormat:@"http://obrazschedule.ru/schedule/?action=get_schedule"];
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //-- Get request and response though URL
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    if (response != nil) {
        //-- JSON Parsing
        NSMutableArray *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"Result = %@",result);
        
        
        
        for (NSMutableDictionary *dic in result)
        {
            NSString *pDate = dic[@"docdate"];
            NSString *hours = dic[@"hours"];
            NSString *minutes = dic[@"minutes"];
            NSString *programName = dic[@"programname"];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-LL-dd' 'HH:mm:ss"];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSDate *date = [dateFormat dateFromString:pDate];
            //2016-08-11 00:00:02

            
            
            Program *curProgram = [[Program alloc] init];
            curProgram.programDate = date;
            curProgram.programName = programName;
            curProgram.hours = [hours intValue];
            curProgram.minutes = [minutes intValue];
            curProgram.programTime = [NSString stringWithFormat:@"%d:%d", curProgram.hours, curProgram.minutes];
            
            [self.programs addObject:curProgram];
            
            
            if (pDate)
            {
                //NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
                //dic[@"array"] = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
            else
            {
                NSLog(@"Error in url response");
            }
            
        }
        [[DBManager getSharedInstance]saveData: self.programs];
               
      }
    
}
-(void)parseJson
{
    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        [self simpleJsonParsing];
        
    });

}
- (void) loadTodayProgram {
    [[DBManager getSharedInstance] clearDB];
    [self parseJson];
    
    NSDate *dbDate = [[DBManager getSharedInstance]getProgramDate];
    NSDate *now = [NSDate date];
    
    if ([dbDate compare:now] == NSOrderedSame) {
       self.programs = [[DBManager getSharedInstance] getTodayProgram];
    } else {
      [[DBManager getSharedInstance] clearDB];
      [self parseJson];
    }
}

@end
