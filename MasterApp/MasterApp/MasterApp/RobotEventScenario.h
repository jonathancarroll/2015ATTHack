//
//  RobotEventScenario.h
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EEScenario;

@interface RobotEventScenario : NSObject

+ (EEScenario *)buildScenario;

@end
