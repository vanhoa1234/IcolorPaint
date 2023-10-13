//
//  House.m
//  Decorator
//
//  Created by Hoang Le on 11/21/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "House.h"

@implementation House
- (id)initWithHouse:(House *)_house{
    self = [super init];
    if (self) {
        _houseID = _house.houseID;
        _houseImage = _house.houseImage;
        _houseImageThumnail = _house.houseImageThumnail;
        _houseName = _house.houseName;
        _date = _house.date;
        _applyPlan = _house.applyPlan;
        _latitude = _house.latitude;
        _longitude = _house.longitude;
        _backgroundImg = _house.backgroundImg;
    }
    return self;
}
@end
