//
//  KMJPZipLookUpResponse.h
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUp.h"

@class KMJPZipLookUpAddress;

@interface KMJPZipLookUpResponse : NSObject

@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSString *requestZipcode;
@property (copy, nonatomic) NSString *resultZipcode;
@property (strong, nonatomic) NSMutableArray *addresses;
// Error
@property (copy, nonatomic) NSString *errorCode;
@property (copy, nonatomic) NSString *errorMessage;

- (void)prepareAddressesWithCapacity:(NSUInteger)capacity;
- (void)addAddress:(KMJPZipLookUpAddress *)address;

- (BOOL)isSuccess;

@end
