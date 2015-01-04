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
    client = [[M2XClient alloc] initWithApiKey:@"5a5c04fa6201f9695b97b176020c4907"];
    [self pollLoop];
    
    return self;
}

-(void)pollLoop {
    [client deviceWithId:@"a7bee74cd9a58ceeec3fcc38fa65193c" completionHandler:^(M2XDevice *device, M2XResponse *response) {
        //NSLog(@"Got device: %@ %@", response, device);
        [device streamsWithCompletionHandler:^(NSArray *objects, M2XResponse *response) {
            //NSLog(@"Got streams: %@ %@", response, objects);
            M2XStream *stream = [objects firstObject];
            NSNumber *value = [stream.attributes objectForKey:@"value"];
            //NSLog(@"Got Value %@", value);
            if(lastTarget1Value == -1) {
                lastTarget1Value = [value intValue];
            } else {
                if(lastTarget1Value < [value intValue]) {
                    lastTarget1Value = [value intValue];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:@"a7bee74cd9a58ceeec3fcc38fa65193c" forKey:@"targetId"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:M2XConnectorTargetHitNotification object:self userInfo:dict];
                }
            }
            
            [self performSelector:@selector(pollLoop) withObject:nil afterDelay:0.5];
        }];
    }];
}

@end
