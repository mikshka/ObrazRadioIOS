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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.player pause];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            if([self.player rate] == 0){
                [self.player play];
            } else {
                [self.player pause];
            }
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self.player play];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self.player pause];
            break;
        default:
            break;
    }
}
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (_isPlaying) {
        [self.player performSelector:@selector(play) withObject:nil afterDelay:0.01];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isPlaying = NO;
    
    
    self.myUrl = [NSURL URLWithString:@"http://213.177.106.78:8002"];
    //NSURL *scheduleUrl = [NSURL URLWithString:@"http://obrazschedule.ru/schedule/?action=get_schedule"];
    
    
    self.programs = [NSMutableArray array];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:self.myUrl];
    self.player = [AVPlayer playerWithPlayerItem: self.playerItem];
    self.player = [AVPlayer playerWithURL:self.myUrl];
    
   
    [self loadTodayProgram];
    
    SEL mySelector = @selector(myTimerCallback:);
    NSTimer* timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:mySelector userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    self.slider.value = vol;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    //NSLog(@"volume = %f", vol);
    
}

-(void)myTimerCallback:(NSTimer*)timer
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
 
    for(int i = 0; i < [self.programs count]; i++) {
        Program *p = [self.programs objectAtIndex:i];
        
        //NSLog(@"i = %d", i);
        int currentTime = hour*60 + minute;
        
        int prTime = p.hours*60 + p.minutes;
        
        if (prTime > currentTime) {
            Program *p2 = [self.programs objectAtIndex:i-1];
            //self.programLabel.selectable = YES;
            NSAttributedString* s2 = [[NSAttributedString alloc] initWithString:p.programName];
           
            self.programLabel.text = p2.programName;
           // self.programLabel.editable = YES;
            //self.programLabel.attributedText = s2;
           // self.programLabel.editable = NO;
            //NSLog(@"%@", p.programName);
            break;
        }
        
        if ((currentTime > prTime) && (i == ([self.programs count] - 1))) {
            self.programLabel.text = p.programName;
            //NSLog(@"%@", p.programName);
            break;
        }
    }
    
    //self.programLabel.text = @"asdasdas";
    
    //NSLog(@"Yes!!!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    UIButton *theButton = (UIButton*)sender;
    if (_isPlaying == NO) {
    
        [self.player play];
        [theButton setImage:[UIImage imageNamed:@"bt_stop.png"] forState:UIControlStateNormal];
        _isPlaying = YES;
        
    } else {
        
        [self.player pause];
      
        [theButton setImage:[UIImage imageNamed:@"bt_play.png"] forState:UIControlStateNormal];
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
      //  NSLog(@"Result = %@",result);
        
        
        
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
    //[self simpleJsonParsing];

}
- (void) loadTodayProgram {
    //[[DBManager getSharedInstance] clearDB];
    //[self parseJson];
   
    
    NSDate *dbDate = [[DBManager getSharedInstance]getProgramDate];
    NSDate *now = [NSDate date];
    
    unsigned int flags = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* componentsdb = [calendar components:flags fromDate:dbDate];
    NSDateComponents* componentsnow = [calendar components:flags fromDate:now];
    
    
    NSDate* db = [calendar dateFromComponents:componentsdb];
    NSDate* n = [calendar dateFromComponents:componentsnow];
    
    
    if (db != nil && [db compare:n] == NSOrderedSame) {
       self.programs = [[DBManager getSharedInstance] getTodayProgram];
    } else {
      [[DBManager getSharedInstance] clearDB];
      [self parseJson];
    }
    
}
- (IBAction) goToUrl {
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://radioobraz.ru/"]];
}
- (IBAction)sliderAction:(id)sender
{
   // [self.player setVolume:self.slider.value];
    
    float val = self.slider.value;
    NSString *version = [[UIDevice currentDevice] systemVersion];
    float ver_float = [version floatValue];
    if (ver_float >= 7.0) {
        if (self.player) {
            self.player.volume = val;
        }
    }
    //self.radioPlayer.volume = self.slider.value;
    /*
    NSLog(@" slider position = %f", val);
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in self.audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:val atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [self.playerItem setAudioMix:audioMix];
     */
}

@end
