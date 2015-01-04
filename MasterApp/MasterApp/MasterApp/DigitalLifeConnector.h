//
//  DigitalLifeConnector.h
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLDevice.h"

#define DigitalLifeConntectorDevicesUpdatedNotification @"DigitalLifeConntectorDevicesUpdatedNotification"

@interface DigitalLifeConnector : NSObject

@property (strong) NSMutableArray *devices;

-(void)updateDevice:(DLDevice*)device attribute:(NSString*)attributeName toValue:(NSString*)value withCompletionHandler:(void (^)(bool success))completion;

+(DigitalLifeConnector*)sharedConnector;

@end
