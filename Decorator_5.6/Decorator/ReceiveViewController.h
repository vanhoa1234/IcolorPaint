//
//  ReceiveViewController.h
//  Decorator
//
//  Created by Hoang Le on 5/19/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ReceiveViewController : UIViewController<CBPeripheralDelegate, CBCentralManagerDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableData *data;
@end
