//
//  EEScenario.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEScenario.h"

@implementation EEScenario

- (id)initWithEvents:(NSArray *)evts {
    self = [super init];
    if (self != nil) {
        self.events = evts;

        return self;
    }

    return nil;
}

@end
