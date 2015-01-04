//
//  EEDeviceStateChangeEvent.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEDeviceStateChangeEvent.h"
#import "DigitalLifeConnector.h"

@implementation EEDeviceStateChangeEvent

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:DigitalLifeConntectorDevicesUpdatedNotification object:nil];

    [super setup];
}

- (void)start {

    [super start];
}

- (void)update:(NSNotification *)notification {
    DigitalLifeConnector *digitalLife = (DigitalLifeConnector *)notification.object;

}

@end
