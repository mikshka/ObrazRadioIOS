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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play
{
    
    NSURL *url = [NSURL URLWithString:@"http://213.177.106.78:8002"];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    self.player = [AVPlayer playerWithPlayerItem: self.playerItem];
    
    self.player = [AVPlayer playerWithURL:url];
    
    [self.player play];
}


@end
