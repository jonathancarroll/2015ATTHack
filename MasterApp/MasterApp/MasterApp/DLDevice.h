//
//  DLDevice.h
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDevice : NSObject

@property (strong) NSString *deviceGuid;
@property (strong) NSString *deviceType;
@property (strong) NSArray *attributes;

@end
