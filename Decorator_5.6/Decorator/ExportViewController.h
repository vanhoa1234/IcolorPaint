//
//  ExportViewController.h
//  Decorator
//
//  Created by Hoang Le on 5/16/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveObject.h"
#import "ZipArchive.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ExportViewController : UIViewController<CBPeripheralManagerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *customCharacteristic;
@property (nonatomic, strong) CBMutableService *customService;
//- (id)initWithFilesToZip:(ArchiveObject *)_archiveObj;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
- (id)initWithZipPath:(NSString *)_zipPath;
@end
