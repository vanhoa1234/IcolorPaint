//
//  KMJPZipLookUpClient.h
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUp.h"
#import "AFHTTPClient.h"

@class AFHTTPRequestOperation;
@class KMJPZipLookUpResponse;

@interface KMJPZipLookUpClient : AFHTTPClient

+ (instancetype)sharedClient;

- (void)lookUpWithZipcode:(NSString *)zipcode
                  success:(void (^)(AFHTTPRequestOperation *, KMJPZipLookUpResponse *))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (BOOL)validateZipcode:(NSString *)zipcode withError:(NSError *__autoreleasing*)error;

@end
