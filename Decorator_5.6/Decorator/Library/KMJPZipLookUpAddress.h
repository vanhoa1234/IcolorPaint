//
//  KMJPZipLookUpAddress.h
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUp.h"

@interface KMJPZipLookUpAddress : NSObject

@property (copy, nonatomic) NSString *prefecture;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *address;

// prefecture + city + address
- (NSString *)fullAddress;
// city + address
- (NSString *)town;

@end
