//
//  EEShootTargetEvent.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEShootTargetEvent.h"
#import "M2XConnector.h"

@implementation EEShootTargetEvent

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(targetHit:) name:M2XConnectorTargetHitNotification object:nil];

    [super setup];
}

- (void)start {
    NSLog(@"Starting shoot target event");
    [super start];
}

- (void)targetHit:(NSNotification *)notification {
    if ([[notification.userInfo objectForKey:@"targetId"] isEqualToString:self.targetId]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self succeed];
    }
}

@end
