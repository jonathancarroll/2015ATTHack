//
//  RobotEventScenario.m
//  MasterApp
//
//  Created by Brandon Dorris on 1/4/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "RobotEventScenario.h"
#import "EEScenario.h"
#import "EEControlEvent.h"
#import "EEPlaySoundEvent.h"
#import "EEDeviceStateChangeEvent.h"
#import "EESound.h"
#import "EEShootTargetEvent.h"

@implementation RobotEventScenario

+ (EEScenario *)buildScenario {
    NSMutableArray *events = [[NSMutableArray alloc] init];

    // TODO: add background music

//     Lights flicker / electricity sounds
    EEControlEvent *controlEvent = [[EEControlEvent alloc] init];
    controlEvent.eventStartSound = [[EESound alloc] initWithSoundId:13 andSpeaker:1];
    [events addObject:controlEvent];

//     ”I’m getting word that robots are invading!”
    EEPlaySoundEvent *soundEvent1 = [[EEPlaySoundEvent alloc] init];
    soundEvent1.eventStartSound = [[EESound alloc] initWithSoundId:0 andSpeaker:1];
    soundEvent1.autoAdvanceDelay = 4.0;
    [events addObject:soundEvent1];

//     “Your front door is unlocked. Lock it before they get here.”
    EEDeviceStateChangeEvent *deviceState1 = [[EEDeviceStateChangeEvent alloc] init];
    deviceState1.eventStartSound = [[EESound alloc] initWithSoundId:1 andSpeaker:1];
//     wait for the door to lock
    deviceState1.deviceType = @"door-lock";
    deviceState1.attributeName = @"lock";
    deviceState1.desiredAttributeState = @"lock";
//     “Good job!”
    deviceState1.eventSuccessSound = [[EESound alloc] initWithSoundId:2 andSpeaker:1];
    deviceState1.successDelay = 2.0;
    [events addObject:deviceState1];

//     “Listen. Do you hear them?” (Distant robot sounds)
    EEPlaySoundEvent *soundEvent2 = [[EEPlaySoundEvent alloc] init];
    soundEvent2.eventStartSound = [[EESound alloc] initWithSoundId:3 andSpeaker:1];
    soundEvent2.autoAdvanceDelay = 4.0;
    [events addObject:soundEvent2];

//      robot sounds
    EEPlaySoundEvent *soundEvent6 = [[EEPlaySoundEvent alloc] init];
    soundEvent6.eventStartSound = [[EESound alloc] initWithSoundId:17 andSpeaker:1];
    soundEvent6.autoAdvanceDelay = 7.0;
    [events addObject:soundEvent6];

    //     crash / gas grenade explosion
    EEPlaySoundEvent *soundEvent7 = [[EEPlaySoundEvent alloc] init];
    soundEvent7.eventStartSound = [[EESound alloc] initWithSoundId:16 andSpeaker:1];
    soundEvent7.autoAdvanceDelay = 4.0;
    [events addObject:soundEvent7];

//     “Oh no! They got a toxic gas grenade in somehow. Open a window to vent the gas.”
    EEDeviceStateChangeEvent *deviceState2 = [[EEDeviceStateChangeEvent alloc] init];
    deviceState2.eventStartSound = [[EESound alloc] initWithSoundId:4 andSpeaker:1];
//     wait for window to open
    deviceState2.deviceType = @"contact-sensor";
    deviceState2.attributeName = @"contact-state";
    deviceState2.desiredAttributeState = @"open";
//     “Good. That should take care of the gas.”
    deviceState2.eventSuccessSound = [[EESound alloc] initWithSoundId:5 andSpeaker:1];
    deviceState2.successDelay = 4.0;
    [events addObject:deviceState2];

//     “Watch out! One of them got in. Quick, SHOOT IT!”
    EEPlaySoundEvent *soundEvent3 = [[EEPlaySoundEvent alloc] init];
    soundEvent3.eventStartSound = [[EESound alloc] initWithSoundId:6 andSpeaker:1];
    soundEvent3.autoAdvanceDelay = 5.5;
    [events addObject:soundEvent3];

//     Noise comes from right side speaker.
    EEShootTargetEvent *shootEvent1 = [[EEShootTargetEvent alloc] init];
    shootEvent1.eventStartSound = [[EESound alloc] initWithSoundId:14 andSpeaker:2];
//     Wait for target to be hit.
    shootEvent1.targetId = @"a7bee74cd9a58ceeec3fcc38fa65193c";
    shootEvent1.eventSuccessSound = [[EESound alloc] initWithSoundId:15 andSpeaker:2];
    [events addObject:shootEvent1];

//     “Great. Now go shut that window so no more get in.”
    EEDeviceStateChangeEvent *deviceState3 = [[EEDeviceStateChangeEvent alloc] init];
    deviceState3.eventStartSound = [[EESound alloc] initWithSoundId:7 andSpeaker:1];
//     Wait for window to shut.
    deviceState3.deviceType = @"contact-sensor";
    deviceState3.attributeName = @"contact-state";
    deviceState3.desiredAttributeState = @"closed";
//     Noise comes from left side speaker.
    deviceState3.eventSuccessSound = [[EESound alloc] initWithSoundId:2 andSpeaker:1];
    deviceState3.successDelay = 2.0;
    [events addObject:deviceState3];

//     shoot the camera
    EEShootTargetEvent *shootEvent2 = [[EEShootTargetEvent alloc] init];
    shootEvent2.eventStartSound = [[EESound alloc] initWithSoundId:18 andSpeaker:1];
//     Wait for target to be hit.
    shootEvent2.targetId = @"0b9b634bd7314a76292c8ab5b9495115";
    shootEvent2.eventSuccessSound = [[EESound alloc] initWithSoundId:15 andSpeaker:1];
    [events addObject:shootEvent2];

    //     “throw in the water.”
    EEDeviceStateChangeEvent *deviceState4 = [[EEDeviceStateChangeEvent alloc] init];
    deviceState4.eventStartSound = [[EESound alloc] initWithSoundId:19 andSpeaker:1];
    //     Wait for water sensor.
    deviceState4.deviceType = @"water-sensor";
    deviceState4.attributeName = @"water-state";
    deviceState4.desiredAttributeState = @"wet";
    //     Noise comes from left side speaker.
    deviceState4.eventSuccessSound = [[EESound alloc] initWithSoundId:15 andSpeaker:0];
    deviceState4.successDelay = 3.0;
    [events addObject:deviceState4];

//     “Excellent work. It looks like they are retreating.”
    EEPlaySoundEvent *soundEvent4 = [[EEPlaySoundEvent alloc] init];
    soundEvent4.eventStartSound = [[EESound alloc] initWithSoundId:9 andSpeaker:1];
    soundEvent4.autoAdvanceDelay = 4.0;
    [events addObject:soundEvent4];

//     “You are safe for now.”
    EEPlaySoundEvent *soundEvent5 = [[EEPlaySoundEvent alloc] init];
    soundEvent5.eventStartSound = [[EESound alloc] initWithSoundId:10 andSpeaker:1];
    soundEvent5.autoAdvanceDelay = 3.0;
    [events addObject:soundEvent5];
    
    return [[EEScenario alloc] initWithEvents:events];
}

@end
