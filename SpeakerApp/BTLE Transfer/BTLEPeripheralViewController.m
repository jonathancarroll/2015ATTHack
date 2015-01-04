/*
 
 File: LEPeripheralViewController.m
 
 Abstract: Interface to allow the user to enter data that will be
 transferred to a version of the app in Central Mode, when it is brought
 close enough.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "BTLEPeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import "OXAudioPlayer.h"
#import "OXAudioManager.h"

@interface BTLEPeripheralViewController () <CBPeripheralManagerDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView           *textView;
@property (strong, nonatomic) IBOutlet UISwitch             *advertisingSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl   *speakerSelector;
@property (strong, nonatomic) CBPeripheralManager           *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic       *transferCharacteristic;
@property (strong, nonatomic) NSData                        *dataToSend;
@property (nonatomic, readwrite) NSInteger                  sendDataIndex;
@property (strong, nonatomic) NSMutableDictionary           *soundPlayers;
@end



#define NOTIFY_MTU          20
#define COMMAND_NODE_NAME   0x00
#define COMMAND_PLAY_SOUND  0x01



@implementation BTLEPeripheralViewController



#pragma mark - View Lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [self.peripheralManager stopAdvertising];

    [super viewWillDisappear:animated];
}



#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{

    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic


    [self setupSounds];
}

- (void)setupSounds {
    self.soundPlayers = [[NSMutableDictionary alloc] init];
    OXAudioPlayer *player0 = [[OXAudioPlayer alloc] initWithFilename:@"0-invading.wav"];
    [self.soundPlayers setObject:player0 forKey:[NSNumber numberWithInt:0]];
    OXAudioPlayer *player1 = [[OXAudioPlayer alloc] initWithFilename:@"1-lockdoor.wav"];
    [self.soundPlayers setObject:player1 forKey:[NSNumber numberWithInt:1]];
    OXAudioPlayer *player2 = [[OXAudioPlayer alloc] initWithFilename:@"2-goodjob.wav"];
    [self.soundPlayers setObject:player2 forKey:[NSNumber numberWithInt:2]];
    OXAudioPlayer *player3 = [[OXAudioPlayer alloc] initWithFilename:@"3-listen.wav"];
    [self.soundPlayers setObject:player3 forKey:[NSNumber numberWithInt:3]];
    OXAudioPlayer *player4 = [[OXAudioPlayer alloc] initWithFilename:@"4-toxicgas.wav"];
    [self.soundPlayers setObject:player4 forKey:[NSNumber numberWithInt:4]];
    OXAudioPlayer *player5 = [[OXAudioPlayer alloc] initWithFilename:@"5-goodgas.wav"];
    [self.soundPlayers setObject:player5 forKey:[NSNumber numberWithInt:5]];
    OXAudioPlayer *player6 = [[OXAudioPlayer alloc] initWithFilename:@"6-shootit1.wav"];
    [self.soundPlayers setObject:player6 forKey:[NSNumber numberWithInt:6]];
    OXAudioPlayer *player7 = [[OXAudioPlayer alloc] initWithFilename:@"7-shutwindow.wav"];
    [self.soundPlayers setObject:player7 forKey:[NSNumber numberWithInt:7]];
    OXAudioPlayer *player8 = [[OXAudioPlayer alloc] initWithFilename:@"8-keepthemout.wav"];
    [self.soundPlayers setObject:player8 forKey:[NSNumber numberWithInt:8]];
    OXAudioPlayer *player9 = [[OXAudioPlayer alloc] initWithFilename:@"9-chased.wav"];
    [self.soundPlayers setObject:player9 forKey:[NSNumber numberWithInt:9]];
    OXAudioPlayer *player10 = [[OXAudioPlayer alloc] initWithFilename:@"10-safe.wav"];
    [self.soundPlayers setObject:player10 forKey:[NSNumber numberWithInt:10]];
    OXAudioPlayer *player11 = [[OXAudioPlayer alloc] initWithFilename:@"11-funny.wav"];
    [self.soundPlayers setObject:player11 forKey:[NSNumber numberWithInt:11]];
    OXAudioPlayer *player12 = [[OXAudioPlayer alloc] initWithFilename:@"Firmware FlagGrab.mp3"];
    [self.soundPlayers setObject:player12 forKey:[NSNumber numberWithInt:12]];
    OXAudioPlayer *player13 = [[OXAudioPlayer alloc] initWithFilename:@"ElectricalArc.wav"];
    [self.soundPlayers setObject:player13 forKey:[NSNumber numberWithInt:13]];
    OXAudioPlayer *player14 = [[OXAudioPlayer alloc] initWithFilename:@"14-robotwalking.wav"];
    [self.soundPlayers setObject:player14 forKey:[NSNumber numberWithInt:14]];
    OXAudioPlayer *player15 = [[OXAudioPlayer alloc] initWithFilename:@"15-robotdeath.wav"];
    [self.soundPlayers setObject:player15 forKey:[NSNumber numberWithInt:15]];
    OXAudioPlayer *player16 = [[OXAudioPlayer alloc] initWithFilename:@"TheGrenadeExplosion.wav"];
    [self.soundPlayers setObject:player16 forKey:[NSNumber numberWithInt:16]];
    OXAudioPlayer *player17 = [[OXAudioPlayer alloc] initWithFilename:@"Robot Turning.wav"];
    [self.soundPlayers setObject:player17 forKey:[NSNumber numberWithInt:17]];

}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    // Get the data
    self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    //[self sendData];
}

-(void) peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    for(CBATTRequest* request in requests){
        // todo - check characteristic UUID
        if (request.value) {
            [self processCommand:request.value];
        }
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)processCommand:(NSData *)data {
    char* commandBytes = [data bytes];
    char command = commandBytes[0];
    NSUInteger length = [data length];
    NSData *body = [data subdataWithRange:NSMakeRange(1, length - 1)];

    if (command == COMMAND_NODE_NAME) {
        NSString* newStr = [NSString stringWithFormat:@"Connected as %@", [NSString stringWithUTF8String:[body bytes]]];
//        NSLog(@"Received: %@", newStr);
        [self.connectedLabel setText:newStr];
    } else if (command == COMMAND_PLAY_SOUND) {
//        int value = CFSwapInt32BigToHost(*(int*)([body bytes]));
        NSString *number = [NSString stringWithUTF8String:[body bytes]];
        NSLog(@"Told to play sound %X", [number intValue]);
        [self playSound:[number intValue]];
    } else if (command == 0x02) {
        [[OXAudioManager sharedManager].playingAudio makeObjectsPerformSelector:@selector(fadeOut)];
    }
}

- (void)playSound:(NSUInteger)soundId {
    OXAudioPlayer *player = [self.soundPlayers objectForKey:[NSNumber numberWithInt:(int)soundId]];
    [player play];
}

/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // nothing
}



#pragma mark - Switch Methods



/** Start advertising
 */
- (IBAction)switchChanged:(id)sender
{
    if (self.advertisingSwitch.on) {self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                                                     properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
                                                                                                          value:nil
                                                                                                    permissions:CBAttributePermissionsWriteable | CBAttributePermissionsReadable];

        NSString *UUID = TRANSFER_SERVICE_UUID_0;
        if (self.speakerSelector.selectedSegmentIndex == 1) {
            UUID = TRANSFER_SERVICE_UUID_1;
        } else if (self.speakerSelector.selectedSegmentIndex == 2) {
            UUID = TRANSFER_SERVICE_UUID_2;
        }

        // Then the service
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:UUID]
                                                                           primary:YES];

        // Add the characteristic to the service
        transferService.characteristics = @[self.transferCharacteristic];
        
        // And add it to the peripheral manager
        [self.peripheralManager addService:transferService];
        
        // All we advertise is our service's UUID
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:UUID]] }];
    }
    
    else {
        [self.peripheralManager stopAdvertising];
    }
}


@end
