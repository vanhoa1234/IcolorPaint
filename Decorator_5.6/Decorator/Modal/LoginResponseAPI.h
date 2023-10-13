//
//  LoginResponseAPI.h
//  Decorator
//
//  Created by Le Hoang on 3/7/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "JSONModel.h"
#import "UserResponse.h"
@interface LoginResponseAPI : JSONModel
@property (nonatomic, strong) NSString *message;
@property (nonatomic) int status;
@property (nonatomic, strong) UserResponse<Optional> *data;
@end
