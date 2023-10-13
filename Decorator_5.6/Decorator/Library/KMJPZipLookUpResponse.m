//
//  KMJPZipLookUpResponse.m
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUpResponse.h"

@implementation KMJPZipLookUpResponse

- (void)prepareAddressesWithCapacity:(NSUInteger)capacity
{
    _addresses = [[NSMutableArray alloc] initWithCapacity:capacity];
}

- (void)addAddress:(KMJPZipLookUpAddress *)address
{
    if (_addresses) {
        [_addresses addObject:address];
    }
}

- (BOOL)isSuccess
{
    return [_code isEqualToString:@"1"];
}

#pragma mark - Debug

- (NSString *)description
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@", [self class]];
    [str appendFormat:@"\n code                 : %@", _code];
    [str appendFormat:@"\n requestZipcode       : %@", _requestZipcode];
    [str appendFormat:@"\n resultZipcode        : %@", _resultZipcode];
    [str appendFormat:@"\n addresses            : %@", _addresses];
    if ([_errorCode length]) {
        [str appendFormat:@"\n errorCode            : %@", _errorCode];
    }
    if ([_errorMessage length]) {
        [str appendFormat:@"\n errorMessage         : %@", _errorMessage];
    }
    return [NSString stringWithString:str];
}

@end
