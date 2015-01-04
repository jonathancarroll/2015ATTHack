//
//  EEBase.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEBase.h"

@implementation EEBase

- (void)setup {
    // nothing
}

- (void)start {
    // nothing
}

- (void)succeed {

    // play success sound
    if (self.delegate) {
        [self.delegate eventFinished:YES];
    }
}

- (void)fail {

    if (self.delegate) {
        [self.delegate eventFinished:NO];
    }
}

@end
