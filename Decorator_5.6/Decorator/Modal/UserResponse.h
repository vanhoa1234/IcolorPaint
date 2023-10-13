//
//  UserResponse.h
//  Decorator
//
//  Created by Le Hoang on 3/2/20.
//  Copyright © 2020 Hoang Le. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserResponse : JSONModel
@property (nonatomic) int userID;
@property (nonatomic, strong) NSString<Optional> *password;
@property (nonatomic, strong) NSString *mail;
@property (nonatomic, strong) NSString *name_sei;
@property (nonatomic, strong) NSString *name_mei;
@property (nonatomic, strong) NSString *furigana_sei;
@property (nonatomic, strong) NSString *furigana_mei;
@property (nonatomic, strong) NSString *kaisyamei;
@property (nonatomic, strong) NSString *busho;
@property (nonatomic, strong) NSString *yakushoku;
@property (nonatomic, strong) NSString *yubin;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *tatemono;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *fax;
@property (nonatomic) int gyoushu;
@property (nonatomic, strong) NSString *gyoushu_sonota;
@property (nonatomic) int send_mail;
@property (nonatomic, strong) NSString *active_token;
@property (nonatomic, strong) NSString *registered_date;
@property (nonatomic) int status;
@end

NS_ASSUME_NONNULL_END
