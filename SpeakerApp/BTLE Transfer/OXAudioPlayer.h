//
//  OXAudioPlayer.h
//  Orbotix
//
//  Created by Jon Carroll on 7/27/11.
//  Copyright 2011 Orbotix, Inc. All rights reserved.
//
//  An audio player class that plays sounds and will mux them.
//  Create instances via initWithFilename:
//  The AVAudioPlayer property is exposed for adjusting the
//  voluming, panning and other details.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface OXAudioPlayer : NSObject {
	AVAudioPlayer	*player;
	BOOL			playing;
	NSURL			*soundFileURL;
    float           fadeVolume;
}

//Exposed AVAudioPlayer instance for the object for playback customization
@property (nonatomic, readonly) AVAudioPlayer	*player;
@property (nonatomic)			NSURL			*soundFileURL;
@property								BOOL			playing;
@property                               float           fadeVolume;
@property                               NSTimeInterval  fadeDuration;

+(OXAudioPlayer*)sharedSound;

//Call to play the audio
-(void)play;

//Init with filname from main bundle (e.g. @"blastoff.wav")
-(id)initWithFilename:(NSString*)filename;

//Slowly fade the audio and stop it
-(void)fadeOut;

//Slowly fade the audio in
-(void)fadeIn;

@end
