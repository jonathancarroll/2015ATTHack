//
//  EEScenarioRunner.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "EEScenarioRunner.h"
#import "EEScenario.h"

@interface EEScenarioRunner () <EEEventDelegate, EESoundDelegate> {
    int eventIndex;
}

@end

@implementation EEScenarioRunner

- (id)initWithScenario:(EEScenario *)scn {
    self = [super init];
    if (self != nil) {
        self.scenario = scn;
        eventIndex = -1;
        return self;
    }

    return nil;
}

- (void)startScenario {
    [self startNextEvent];
}

- (void)startNextEvent {
    eventIndex++;
    if (eventIndex < [self.scenario.events count]) {
        EEBase *event = [self.scenario.events objectAtIndex:0];
        event.soundDelegate = self;
        event.eventDelegate = self;
        [event setup];
        [event start];
    } else {
        [self endScenario];
    }
}

- (void)endScenario {
    if (self.scenarioDelegate) {
        [self.scenarioDelegate scenarioEnded];
    }
}

- (void)eventFinished:(BOOL)success {
    if (success) {
        [self startNextEvent];
    } else {
        // TODO: do something different here
        [self endScenario];
    }
}

- (void)playSound:(NSUInteger)soundId onSpeaker:(NSUInteger)speakerId {
    if (self.soundDelegate) {
        [self.soundDelegate playSound:soundId onSpeaker:speakerId];
    }
}

@end
