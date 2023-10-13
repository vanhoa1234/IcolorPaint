//
//  KMJPZipLookUpAddress.m
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUpAddress.h"

@implementation KMJPZipLookUpAddress

- (NSString *)fullAddress
{
    NSMutableString *str = [NSMutableString string];
    if ([_prefecture length] > 0) {
        [str appendString:_prefecture];
    }
    if ([_city length] > 0) {
        [str appendString:_city];
    }
    if ([_address length] > 0) {
        [str appendString:_address];
    }
    return [NSString stringWithString:str];
}

- (NSString *)town
{
    NSMutableString *str = [NSMutableString string];
    if ([_city length] > 0) {
        [str appendString:_city];
    }
    if ([_address length] > 0) {
        [str appendString:_address];
    }
    return [NSString stringWithString:str];
}

#pragma mark - Debug

- (NSString *)description
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@", [self class]];
    [str appendFormat:@"\n prefecture       : %@", _prefecture];
    [str appendFormat:@"\n city             : %@", _city];
    [str appendFormat:@"\n address          : %@", _address];
    return [NSString stringWithString:str];
}

@end
