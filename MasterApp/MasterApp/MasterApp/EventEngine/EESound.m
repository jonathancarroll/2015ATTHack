//
//  EESound.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EESound.h"

@implementation EESound

-(id)initWithSoundId:(NSUInteger)sid andSpeaker:(NSUInteger)speaker {
    self = [super init];
    if (self != nil) {
        self.soundId = sid;
        self.desiredSpeaker = speaker;
        return self;
    }

    return nil;
}

@end
