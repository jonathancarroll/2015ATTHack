//
//  M2XConnector.m
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "M2XConnector.h"

@implementation M2XConnector

-(id)init {
    self = [super init];
    lastTarget1Value = -1;
    lastTarget2Value = -1;
    client = [[M2XClient alloc] initWithApiKey:@"5a5c04fa6201f9695b97b176020c4907"];
    client2 = [[M2XClient alloc] initWithApiKey:@"a1c50cf6f75fc1f2e1e383557eff6cfd"];
    [self pollLoop];
    [self pollLoop2];
    
    return self;
}

-(void)pollLoop {
    [client deviceWithId:@"a7bee74cd9a58ceeec3fcc38fa65193c" completionHandler:^(M2XDevice *device, M2XResponse *response) {
        //NSLog(@"Got device: %@ %@", response, device);
        [device streamsWithCompletionHandler:^(NSArray *objects, M2XResponse *response) {
            //NSLog(@"Got streams: %@ %@", response, objects);
            M2XStream *stream = [objects firstObject];
            NSNumber *value = [stream.attributes objectForKey:@"value"];
            //NSLog(@"Got Value T1 %@", value);
            if(lastTarget1Value == -1) {
                lastTarget1Value = [value intValue];
            } else {
                if(lastTarget1Value != [value intValue]) {
                    lastTarget1Value = [value intValue];
                    NSLog(@"HIT!!!!!!!1111111");
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:@"a7bee74cd9a58ceeec3fcc38fa65193c" forKey:@"targetId"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:M2XConnectorTargetHitNotification object:self userInfo:dict];
                }
            }
            
            [self performSelector:@selector(pollLoop) withObject:nil afterDelay:0.5];
        }];
    }];
}

-(void)pollLoop2 {
    [client2 deviceWithId:@"0b9b634bd7314a76292c8ab5b9495115" completionHandler:^(M2XDevice *device, M2XResponse *response) {
        //NSLog(@"Got device: %@ %@", response, device);
        [device streamsWithCompletionHandler:^(NSArray *objects, M2XResponse *response) {
            //NSLog(@"Got streams: %@ %@", response, objects);
            M2XStream *stream = [objects firstObject];
            NSNumber *value = [stream.attributes objectForKey:@"value"];
            //NSLog(@"Got Value T2 %@", value);
            if(lastTarget2Value == -1) {
                lastTarget2Value = [value intValue];
            } else {
                if(lastTarget2Value != [value intValue]) {
                    lastTarget2Value = [value intValue];
                    NSLog(@"HIT!!!!!!!222222");
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:@"0b9b634bd7314a76292c8ab5b9495115" forKey:@"targetId"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:M2XConnectorTargetHitNotification object:self userInfo:dict];
                }
            }
            
            [self performSelector:@selector(pollLoop2) withObject:nil afterDelay:0.5];
        }];
    }];
}

@end
