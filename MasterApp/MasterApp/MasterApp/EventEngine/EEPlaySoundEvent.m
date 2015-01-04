//
//  EEPlaySoundEvent.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEPlaySoundEvent.h"

@implementation EEPlaySoundEvent

- (void)setup {
    [super setup];
}

- (void)start {
    [super start];

    [self performSelector:@selector(continue) withObject:nil afterDelay:self.autoAdvanceDelay];
}

- (void)continue {
    [self succeed];
}

@end
