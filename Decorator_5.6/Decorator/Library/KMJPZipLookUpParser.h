//
//  KMJPZipLookUpParser.h
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUp.h"

@class KMJPZipLookUpResponse;

@interface KMJPZipLookUpParser : NSObject <NSXMLParserDelegate>

@property (readonly, nonatomic) KMJPZipLookUpResponse *response;
@property (readonly, nonatomic) NSError *error;

@end
