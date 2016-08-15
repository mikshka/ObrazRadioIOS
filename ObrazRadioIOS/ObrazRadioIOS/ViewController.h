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


@interface ViewController : UIViewController

@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;

@property(nonatomic) bool isPlaying;

- (IBAction)play;
+ (NSMutableDictionary *)jsonRequestWithURL:(NSString *)url;
- (void)simpleJsonParsing;
- (void) parseJson;


@end
