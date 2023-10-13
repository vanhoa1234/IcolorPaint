//
//  UserInfo.m
//  Decorator
//
//  Created by Hoang Le on 6/17/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"userID"}];
}
@end
