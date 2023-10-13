//
//  DecoratorUtil.h
//  Decorator
//
//  Created by Hoang Le on 12/4/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "House.h"
#import "Plan.h"
#import "Material.h"
#define     kUserName           @"User Name"

#define     kLoginOfficerName          @"Login Officer Name"
#define     kOfficerPassword           @"OfficerPassword"
#define     kIsCorrectUserPass  @"IsCorrectUserPass"

#define     kNameOder           @"Name Oder"
#define     kAddressOder        @"Address Oder"
#define     kPhoneNumberOder    @"Phone Number Oder"
#define     kEmailOder          @"Email Oder"

#define     kNameStore          @"Name Store"
#define     kEmailStore         @"Email Store"
#define     kOfficeOfSuzukafine @"Office of Suzukafine"
#define     kCCEmaillStore      @"CC Email Store"
#define     kAddress            @"Address"

#define     kZipcode            @"Zipcode"
#define     kFax                @"Fax"
#define     kStoreFax           @"Store Fax"
#define     kStorePhone         @"Store Phone"
#define     kMobilePhone        @"Mobile Phone"
#define     kAddress2           @"Second Address"

#define     kLockPassword       @"Lock Password"

#define     kLoginUserName      @"Login Username"
#define     kUserPassword       @"UserPassword"

#define     kAutosaveTime       @"Autosave Time"

#define     kUserID             @"User ID"

@interface DecoratorUtil : NSObject
//+ (NSString *)generateOrderEmail:(NSArray *)_houses;
+ (NSString *)generateOrderEmail:(House *)_house andPlan:(NSArray *)plans;
+ (NSString *)generateOrderEmail:(House *)_house andPlan:(NSArray *)plans andMaterial:(NSArray *)materials;
+ (NSString *)generateOrderEmailWithMaterials:(NSArray *)materials;
+ (NSString *)getMaterialIcon:(int)_type andKind:(NSString *)_kind;

+ (NSString *)getTypeImageByID:(int)_type;
+ (NSString *)getTypeNameByID:(int)_type;
@end
