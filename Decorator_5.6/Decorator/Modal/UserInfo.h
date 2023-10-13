//
//  UserInfo.h
//  Decorator
//
//  Created by Hoang Le on 6/17/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "JSONModel.h"

@interface UserInfo : JSONModel
@property (nonatomic) int userID;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *address2;
@property (nonatomic, strong) NSString *company_name;
@property (nonatomic, strong) NSDate *created_date;
@property (nonatomic) int delete_status;
@property (nonatomic, strong) NSString *login_name;
@property (nonatomic, strong) NSString *login_password;
@property (nonatomic, strong) NSString *mail;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *store;
@property (nonatomic, strong) NSString *store_mail;
@property (nonatomic, strong) NSString *suzuka;
@property (nonatomic, strong) NSString *suzuka_mail;
@property (nonatomic, strong) NSDate *updated_date;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *fax;
@property (nonatomic, strong) NSString *store_fax;
@property (nonatomic, strong) NSString *store_phone_number;
@property (nonatomic, strong) NSString *mobile_number;
@end
