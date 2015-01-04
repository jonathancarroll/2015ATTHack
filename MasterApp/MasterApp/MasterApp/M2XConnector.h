//
//  M2XConnector.h
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2X.h"

#define M2XConnectorTargetHitNotification @"M2XTargetHitNotification"

@interface M2XConnector : NSObject {
    M2XClient *client;
    M2XClient *client2;
    int lastTarget1Value;
    int lastTarget2Value;
}

@end
