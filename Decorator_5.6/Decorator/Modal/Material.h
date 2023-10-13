//
//  Material.h
//  Decorator
//
//  Created by Hoang Le on 11/21/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"
@protocol Material
@end
@interface Material : FCModel
@property (nonatomic, assign) int64_t materialID;
@property (nonatomic, assign) int64_t planID;
@property (nonatomic, assign) int64_t type;
@property (nonatomic, copy) NSString *colorCode;
@property (nonatomic, copy) NSString *feature;
@property (nonatomic, copy) NSString *gloss;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *imageLink;

@property (nonatomic, copy) NSString *patternImage;
@property (nonatomic, assign) int64_t R1;
@property (nonatomic, assign) int64_t G1;
@property (nonatomic, assign) int64_t B1;
@property (nonatomic, assign) int64_t No;

@property (nonatomic, assign) int64_t transparent;  //QuyPV Add
@end
