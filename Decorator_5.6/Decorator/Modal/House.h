//
//  House.h
//  Decorator
//
//  Created by Hoang Le on 11/21/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@interface House : FCModel
@property (nonatomic, assign) int houseID;
@property (nonatomic, copy) NSString *houseName;
@property (nonatomic, copy) NSString *houseImage;
@property (nonatomic, copy) NSString *houseImageThumnail;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *applyPlan;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic, copy) NSString<Optional> *backgroundImg;
- (id)initWithHouse:(House *)_house;
@end
