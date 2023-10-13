//
//  ResponseAPI.h
//  Decorator
//
//  Created by Hoang Le on 6/17/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "JSONModel.h"
#import "UserInfo.h"
@interface ResponseAPI : JSONModel
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) UserInfo<Optional> *infor;
@end
