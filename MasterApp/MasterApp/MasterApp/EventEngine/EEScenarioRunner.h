//
//  EEScenarioRunner.h
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEBase.h"

@class EEScenario;

@protocol EEScenarioDelegate <NSObject>

- (void)scenarioEnded;

@end

@interface EEScenarioRunner : NSObject

@property (strong, nonatomic) EEScenario *scenario;
@property (weak) id<EESoundDelegate> soundDelegate;
@property (weak) id<EEScenarioDelegate> scenarioDelegate;

- (id)initWithScenario:(EEScenario *)scn;
- (void)startScenario;

@end
