//
//  M2XConnector.h
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2X.h"

@interface M2XConnector : NSObject {
    M2XClient *client;
    int lastTarget1Value;
}

@end
