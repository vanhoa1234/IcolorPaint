//
//  ArchiveObject.h
//  Decorator
//
//  Created by Hoang Le on 5/15/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "House.h"
#import "JSONModel.h"
#import "Plan.h"
#import "Material.h"
#import "LayoutPosition.h"
#import "Comment.h"

@interface ArchiveObject : JSONModel
@property (nonatomic, strong) House<ConvertOnDemand> *houseObj;
@property (nonatomic, strong) NSArray<Plan, ConvertOnDemand> *plans;
@property (nonatomic, strong) NSMutableArray<Material, ConvertOnDemand> *materials;
@property (nonatomic, strong) NSArray<LayoutPosition,ConvertOnDemand,Optional> *layoutPosition;
@property (nonatomic, strong) NSArray<Comment,ConvertOnDemand,Optional> *comments;
@property (nonatomic) NSNumber<Optional> *isPhone;
@end
