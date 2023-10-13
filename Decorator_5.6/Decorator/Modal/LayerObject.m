//
//  LayerObject.m
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "LayerObject.h"

@implementation LayerObject
@synthesize type;
@synthesize image;
@synthesize name;
@synthesize color;
@synthesize mask;
@synthesize colorValue;
@synthesize patternImage;

@synthesize feature;
@synthesize gloss;
@synthesize pattern;
@end

@implementation ActionObject
@synthesize action_type;
//@synthesize layer_type;
//@synthesize layer_type_post;
//@synthesize colorValue;
//@synthesize colorValue_post;
@synthesize index;
@synthesize index_post;
@end
