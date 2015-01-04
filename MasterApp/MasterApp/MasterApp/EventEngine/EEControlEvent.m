//
//  EEControlEvent.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEControlEvent.h"
#import "DLDevice.h"
#import "DigitalLifeConnector.h"

@implementation EEControlEvent

- (void)setup {
    
    loopCount = 0;
    [super setup];
}

-(DLDevice*)getPlug {
    for(DLDevice *device in [DigitalLifeConnector sharedConnector].devices) {
        if([device.deviceType isEqualToString:@"smart-plug"]) {
            return device;
        }
    }
    return nil;
}

- (void)start {
    // run routine and then finish
    [super start];
    
    [[DigitalLifeConnector sharedConnector] updateDevice:[self getPlug] attribute:@"switch" toValue:@"off" withCompletionHandler:^(bool success) {
        [self performSelector:@selector(phase1) withObject:nil afterDelay:0.2];
    }];
    
}

-(void)phase1 {
    [[DigitalLifeConnector sharedConnector] updateDevice:[self getPlug] attribute:@"switch" toValue:@"on" withCompletionHandler:^(bool success) {
        [self performSelector:@selector(phase2) withObject:nil afterDelay:0.5];
    }];
}

-(void)phase2 {
    [[DigitalLifeConnector sharedConnector] updateDevice:[self getPlug] attribute:@"switch" toValue:@"off" withCompletionHandler:^(bool success) {
        [self performSelector:@selector(phase3) withObject:nil afterDelay:0.3];
    }];
}

-(void)phase3 {
    [[DigitalLifeConnector sharedConnector] updateDevice:[self getPlug] attribute:@"switch" toValue:@"on" withCompletionHandler:^(bool success) {
        [self performSelector:@selector(phase4) withObject:nil afterDelay:0.6];
    }];
}

-(void)phase4 {
    [[DigitalLifeConnector sharedConnector] updateDevice:[self getPlug] attribute:@"switch" toValue:@"off" withCompletionHandler:^(bool success) {
        
        if(loopCount < 6) {
            loopCount++;
            [self performSelector:@selector(phase1) withObject:nil afterDelay:0.3];
        } else {
            [self succeed];
        }
    }];
}
@end
