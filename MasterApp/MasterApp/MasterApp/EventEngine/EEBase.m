//
//  EEBase.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEBase.h"
#import "EESound.h"

@implementation EEBase

- (void)setup {
    // nothing
}

- (void)start {

    if (self.soundDelegate && self.eventStartSound) {
        [self.soundDelegate playSound:self.eventStartSound.soundId onSpeaker:self.eventStartSound.desiredSpeaker];
    }
}

- (void)succeed {

    if (self.soundDelegate && self.eventSuccessSound) {
        [self.soundDelegate playSound:self.eventSuccessSound.soundId onSpeaker:self.eventSuccessSound.desiredSpeaker];
    }

    if (self.successDelay > 0) {
        [self performSelector:@selector(finished:) withObject:[NSNumber numberWithBool:YES] afterDelay:self.successDelay];
    } else {
        [self finished:YES];
    }

}

- (void)finished:(BOOL)success {
    if (self.eventDelegate) {
        [self.eventDelegate eventFinished:YES];
    }
}

- (void)fail {
    
    if (self.eventDelegate) {
        [self.eventDelegate eventFinished:NO];
    }
}

@end
