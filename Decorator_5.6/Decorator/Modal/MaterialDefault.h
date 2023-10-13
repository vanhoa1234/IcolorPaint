//
//  MaterialDefault.h
//  Decorator
//
//  Created by Hoang Le on 5/13/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@interface MaterialDefault : FCModel
@property (nonatomic, assign) int64_t type;
@property (nonatomic, copy) NSString *feature;
@property (nonatomic, copy) NSString *gloss;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, assign) int64_t isPattern;
@end
