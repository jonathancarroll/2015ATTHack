//
//  EEDeviceStateChangeEvent.h
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEBase.h"

@interface EEDeviceStateChangeEvent : EEBase

@property (strong, nonatomic) NSString *deviceType;
@property (strong, nonatomic) NSString *attributeName;
@property (strong, nonatomic) NSString *desiredAttributeState;

@end
