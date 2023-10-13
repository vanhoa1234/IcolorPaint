//
//  Comment.h
//  Decorator
//
//  Created by Le Hoang on 3/1/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@protocol Comment
@end

@interface Comment : FCModel
@property (nonatomic) int64_t commentID;
@property (nonatomic) int64_t houseID;
@property (nonatomic, strong) NSString *content;
@property (nonatomic) float xValue;
@property (nonatomic) float yValue;
@property (nonatomic) float width;
@property (nonatomic) float height;
@end
