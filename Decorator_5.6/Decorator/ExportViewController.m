//
//  ExportViewController.m
//  Decorator
//
//  Created by Hoang Le on 5/16/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "ExportViewController.h"

@interface ExportViewController (){
    ArchiveObject *archiveObject;
    
}
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic, strong) NSString *zipPath;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@end

@implementation ExportViewController
@synthesize peripheralManager;
static NSString * const kServiceUUID = @"2D1D78EE-3281-4431-865C-FD8863426D0A";
static NSString * const kCharacteristicUUID = @"5A48EFFE-5B82-48B0-8908-9D4E46FA3A7E";
static int NOTIFY_MTU = 20;

- (id)initWithFilesToZip:(ArchiveObject *)_archiveObj{
    self = [super init];
    if (self) {
        archiveObject = _archiveObj;
    }
    return self;
}

- (id)initWithZipPath:(NSString *)_zipFilePath{
    self = [super init];
    if (self) {
        self.zipPath = _zipFilePath;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Peripheral manager delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            break;
        default:
            NSLog(@"Peripheral Manager did change state");
            _lbStatus.text = @"Peripheral Manager did change state";
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error == nil) {
        // Starts advertising the service
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : @"ICServer", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    if([[NSFileManager defaultManager] fileExistsAtPath:_zipPath])
    {
        self.dataToSend = [[NSFileManager defaultManager] contentsAtPath:_zipPath];
    }
        else
    {
        NSLog(@"File not exits");
    }
    self.sendDataIndex = 0;
    [self sendData];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self sendData];
}

#pragma mark - setup peripheral
- (void)setupService {
    // Creates the characteristic UUID
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    
    // Creates the characteristic
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    // Creates the service UUID
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    // Creates the service and adds the characteristic to it
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    // Sets the characteristics for this service
    [self.customService setCharacteristics:@[self.customCharacteristic]];
    
    // Publishes the service
    [self.peripheralManager addService:self.customService];
}

#pragma mark - send data
- (void)sendData {
    
    static BOOL sendingEOM = NO;
    
    // end of message?
    if (sendingEOM) {
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.customCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            // It did, so mark it as sent
            sendingEOM = NO;
        }
        // didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
//    NSLog(@"zip path %@",_zipPath);
//    NSLog(@"data to send %ld, data index %ld",(unsigned long)self.dataToSend.length, self.sendDataIndex);
    // We're sending data
    // Is there any left to send?
    if (self.sendDataIndex >= self.dataToSend.length) {
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
    
    while (didSend) {
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.customCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
//        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.customCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                NSLog(@"Sent: EOM");
                _lbStatus.text = @"Sent EOM";
            }
    
            return;
        }
    }
}
@end
