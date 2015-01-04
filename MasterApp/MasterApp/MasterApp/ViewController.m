//
//  ViewController.m
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import "EEScenarioRunner.h"
#import "RobotEventScenario.h"
#import "EEBase.h"

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, EESoundDelegate, EEScenarioDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) NSMutableArray        *peripherals;
@property (strong, nonatomic) NSMutableArray        *peripheralsConnecting;
@property (strong, nonatomic) NSMutableDictionary   *characteristics;
@property (strong, nonatomic) EEScenarioRunner      *scenarioRunner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dl = [[DigitalLifeConnector alloc] init];

    m2x = [[M2XConnector alloc] init];
_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");

    [super viewWillDisappear:animated];
}

#pragma mark - Scenario Methods

- (void)loadScenario {
    EEScenario *scenario = [RobotEventScenario buildScenario];
    self.scenarioRunner = [[EEScenarioRunner alloc] initWithScenario:scenario];
    self.scenarioRunner.soundDelegate = self;
    self.scenarioRunner.scenarioDelegate = self;
}

- (void)startScenario {
    [self.scenarioRunner startScenario];
}

- (void)scenarioEnded {
    // TODO: do something
}

#pragma mark - Central Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }

    [self scan];
}


- (void)scan
{
    if (self.peripherals) {
        [self.peripheralsConnecting removeAllObjects];
        [self.peripherals removeAllObjects];
        [self.characteristics removeAllObjects];
    } else {
        self.peripheralsConnecting = [[NSMutableArray alloc] init];
        self.peripherals = [[NSMutableArray alloc] init];
        self.characteristics = [[NSMutableDictionary alloc] init];
    }
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

    NSLog(@"Scanning started");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (RSSI.integerValue > -15) {
        return;
    }

    if (RSSI.integerValue < -35) {
        return;
    }

    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);

    if (![self.peripherals containsObject:peripheral] && ![self.peripheralsConnecting containsObject:peripheral]) {
        NSLog(@"Attempting to connect to peripheral %@", peripheral);
        [self.peripheralsConnecting addObject:peripheral];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)playSound:(NSUInteger)soundId onSpeaker:(NSUInteger)speakerId {
    if ([self.peripherals objectAtIndex:speakerId]) {
        CBPeripheral *peripheral = [self.peripherals objectAtIndex:speakerId];
        CBCharacteristic *characteristic = [self.characteristics objectForKey:peripheral];
        char* stuff[1];
        stuff[0] = 0x01;
        NSString *name = [NSString stringWithFormat:@"%d", (int)soundId];
        NSMutableData *data = [NSMutableData dataWithBytes:stuff length:1];
        [data appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}

- (void)namePeripheral:(NSUInteger)index withName:(NSString *)name {
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:index];
    CBCharacteristic *characteristic = [self.characteristics objectForKey:peripheral];
    char* stuff[1];
    stuff[0] = 0x00;
    NSMutableData *data = [NSMutableData dataWithBytes:stuff length:1];
    [data appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");

    if (![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
        [self.peripheralsConnecting removeObject:peripheral];
        NSLog(@"Connecting to peripheral %@", peripheral);

        // Make sure we get the discovery callbacks
        peripheral.delegate = self;

        // Search only for services that match our UUID
        [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral Disconnected");

    [self.peripherals removeObject:peripheral];
    [self.characteristics removeObjectForKey:peripheral];

    NSDictionary* connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey: @YES};

    NSLog(@"Trying to reconnect...");
    [self.centralManager connectPeripheral:peripheral options:connectOptions];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }

    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [self.characteristics setObject:characteristic forKey:peripheral];
            NSUInteger index = [self.peripherals indexOfObject:peripheral];
            [self namePeripheral:index withName:[NSString stringWithFormat:@"Speaker %d", (int)index]];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }

    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

    NSLog(@"Received: %@", stringFromData);
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }

    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }

    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }

    else {
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)cleanup
{
    for (CBPeripheral *peripheral in self.peripherals) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

@end
