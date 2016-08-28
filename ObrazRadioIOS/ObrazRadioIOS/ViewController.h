//
//  ViewController.h
//  ObrazRadioIOS
//
//  Created by Михаил Коршунов on 01.08.16.
//  Copyright © 2016 Михаил Коршунов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioToolbox/AudioFileStream.h>
#include <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "DBManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSMutableArray *programs;
@property (nonatomic, retain) IBOutlet UITextView *programLabel;
@property (nonatomic, retain) IBOutlet UIButton *siteButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property(nonatomic) bool isPlaying;

- (void)myTimerCallback:(NSTimer*)timer;
- (IBAction)play:(id)sender;
+ (NSMutableDictionary *)jsonRequestWithURL:(NSString *)url;
- (void)simpleJsonParsing;
- (void) parseJson;
- (void) loadTodayProgram;
- (IBAction) goToUrl;
- (IBAction)sliderAction:(id)sender;

@end

