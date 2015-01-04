//
//  OXAudioPlayer.m
//  Orbotix
//
//  Created by Jon Carroll on 7/27/11.
//  Copyright 2011 Orbotix, Inc. All rights reserved.
//

#import "OXAudioPlayer.h"
#import "OXAudioManager.h"

@implementation OXAudioPlayer

@synthesize player, playing, soundFileURL, fadeVolume, fadeDuration;

+(OXAudioPlayer*)sharedSound {
    return nil;
}

-(void)play {
	if(playing) return;
	[[OXAudioManager sharedManager] playingAudio:self];
    [player setCurrentTime:0.0];
	[player play];
}

-(id)initWithFilename:(NSString*)filename {
	self = [super init];
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:soundFilePath];
	self.soundFileURL = url;

	player = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
	
	playing = NO;
    fadeDuration = 1.5;
	
    // Must set delegate first to initialize audio manager correctly.
	[player setDelegate:[OXAudioManager sharedManager]];
	[player prepareToPlay];
	[player setVolume:1.0];
	
	return self;
}

-(void)fadeOut {
    float inc = player.volume / (fadeDuration * 20.0);
    NSNumber *increment = [NSNumber numberWithFloat:inc];
    [self performSelector:@selector(fadeOutLoop:) withObject:increment];
}

-(void)fadeOutLoop:(NSNumber*)increment {
    player.volume -= [increment floatValue];
    
    if(player.volume > 0.0) {
        [self performSelector:@selector(fadeOutLoop:) withObject:increment afterDelay:0.05];
    } else {
        [player stop];
        playing = NO;
    }
}

-(void)fadeIn {
    playing = YES;
    float inc = fadeVolume / (fadeDuration * 20.0);
    NSNumber *increment = [NSNumber numberWithFloat:inc];
    player.volume = 0.0;
    [player play];
    [self performSelector:@selector(fadeInLoop:) withObject:increment];
}

-(void)fadeInLoop:(NSNumber*)increment {
    player.volume += [increment floatValue];
    
    if(player.volume < fadeVolume) {
        [self performSelector:@selector(fadeInLoop:) withObject:increment afterDelay:0.05];
    }
}


@end
