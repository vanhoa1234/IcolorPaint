//
//  KMJPZipLookUp.h
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#ifndef KMJPZipLookUpSample_KMJPZipLookUp_h
#define KMJPZipLookUpSample_KMJPZipLookUp_h

#import <Foundation/Foundation.h>
#import "KMJPZipLookUpClient.h"
#import "KMJPZipLookUpParser.h"
#import "KMJPZipLookUpResponse.h"
#import "KMJPZipLookUpAddress.h"

static NSString * const KMJPZipLookUpErrorDomain = @"KMJPZipLookUpErrorDomain";

typedef enum {
    KMJPZipLookUpErrorTypeAPIError,
    KMJPZipLookUpErrorTypeRequestParameterInvalid
} KMJPZipLookUpErrorType;

#endif
