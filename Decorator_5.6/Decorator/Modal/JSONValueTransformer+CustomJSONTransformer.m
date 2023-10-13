//
//  JSONValueTransformer+CustomJSONTransformer.m
//  Decorator
//
//  Created by Hoang Le on 6/17/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "JSONValueTransformer+CustomJSONTransformer.h"

@implementation JSONValueTransformer (CustomJSONTransformer)

- (NSDate *)NSDateFromNSString:(NSString*)string {
    return [NSDate dateWithTimeIntervalSince1970:[string intValue]];
}
@end
