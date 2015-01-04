//
//  EEBase.h
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#ifndef MasterApp_EEBase_h
#define MasterApp_EEBase_h

#import <Foundation/Foundation.h>

@protocol EEEventDelegate <NSObject>

@required

- (void)eventFinished:(BOOL)success;

@end

@protocol EESoundDelegate <NSObject>

- (void)playSound:(NSUInteger)soundId onSpeaker:(NSUInteger)speakerId;

@end

@class EESound;

@interface EEBase : NSObject

@property (strong, nonatomic) EESound *eventStartSound;
@property (strong, nonatomic) EESound *eventSuccessSound;
@property (nonatomic) NSTimeInterval autoAdvanceDelay;
@property (weak) id<EEEventDelegate> eventDelegate;
@property (weak) id<EESoundDelegate> soundDelegate;

- (void)setup;
- (void)start;
- (void)succeed;
- (void)fail;

@end

#endif
