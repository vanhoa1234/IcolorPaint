//
//  Feature.h
//  Decorator
//
//  Created by Hoang Le on 11/21/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@interface Feature : FCModel
@property (nonatomic, assign) int64_t featureID;
@property (nonatomic, copy) NSString *featureName;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, assign) int64_t type;
@property (nonatomic, copy) NSString *glossRef;
@property (nonatomic, copy) NSString *patternRef;
@end
