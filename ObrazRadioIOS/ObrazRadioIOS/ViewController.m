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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isPlaying = NO;
    
    NSURL *url = [NSURL URLWithString:@"http://213.177.106.78:8002"];
    NSURL *scheduleUrl = [NSURL URLWithString:@"http://obrazschedule.ru/schedule/?action=get_schedule"];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem: self.playerItem];
    self.player = [AVPlayer playerWithURL:url];
    
    [self simpleJsonParsing];
    
    
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
    
    //-- JSON Parsing
    NSMutableArray *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"Result = %@",result);
    
    for (NSMutableDictionary *dic in result)
    {
        NSString *string = dic[@"array"];
        if (string)
        {
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            dic[@"array"] = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else
        {
            NSLog(@"Error in url response");
        }
    }
    
}

@end
