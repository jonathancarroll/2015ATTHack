//
//  EEDeviceStateChangeEvent.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEDeviceStateChangeEvent.h"
#import "DigitalLifeConnector.h"
#import "DLDevice.h"

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

    bool pass = YES; //Assume success
    for(DLDevice *device in digitalLife.devices) {
        if([device.deviceType isEqualToString:self.deviceType]) {
            for(NSDictionary *d in device.attributes) {
                if([[d objectForKey:@"label"] isEqualToString:self.attributeName]) {
                    if(![[d objectForKey:@"value"] isEqualToString:self.desiredAttributeState]) {
                        pass = false; //Fail there is a device of this type not in the right state
                    }
                }
            }
        }
    }
    
    if(pass) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self succeed];
    }
    
}

@end
