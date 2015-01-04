//
//  ViewController.h
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DigitalLifeConnector.h"
#import "M2XConnector.h"

@interface ViewController : UIViewController {
    DigitalLifeConnector *dl;
    M2XConnector *m2x;
    IBOutlet UIButton *startButton;
    
}


@end

