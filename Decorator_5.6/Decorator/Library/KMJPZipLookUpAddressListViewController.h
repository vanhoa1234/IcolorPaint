//
//  KMJPZipLookUpAddressListViewController.h
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMJPZipLookUp.h"

extern NSString *kKMJPZipLookUpAddressListDidSelectNotification;
extern NSString *kKMJPZipLookUpAddressListResultsKey;

@class KMJPZipLookUpResponse;

@interface KMJPZipLookUpAddressListViewController : UITableViewController

@property (strong, nonatomic) KMJPZipLookUpResponse *response;

@end
