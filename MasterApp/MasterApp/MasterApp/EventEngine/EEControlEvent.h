//
//  EEControlEvent.h
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEBase.h"

@interface EEControlEvent : EEBase {
    int loopCount;
}

@property (strong, nonatomic) NSString *deviceType;

@end
