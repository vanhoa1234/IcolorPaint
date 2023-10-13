//
//  UserResponse.m
//  Decorator
//
//  Created by Le Hoang on 3/2/20.
//  Copyright © 2020 Hoang Le. All rights reserved.
//

#import "UserResponse.h"

@implementation UserResponse

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"userID"}];
}
@end
