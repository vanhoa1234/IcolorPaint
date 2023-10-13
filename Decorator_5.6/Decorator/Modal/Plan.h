//
//  Plan.h
//  Decorator
//
//  Created by Hoang Le on 11/21/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"
@protocol Plan
@end

@interface Plan : FCModel
@property (nonatomic, assign) int planID;
@property (nonatomic, copy) NSString *imageLink;
@property (nonatomic, copy) NSString *planName;
@property (nonatomic, assign) int applyPlan;
@property (nonatomic, assign) int houseID;
@property (nonatomic, copy) NSString *planIndex;
@end
