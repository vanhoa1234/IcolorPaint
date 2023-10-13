//
//  LayerObject.h
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Mask.h"
#import "Color.h"
typedef enum {
    LAYER_NOPAINT = 0,
    LAYER_BALUSTRADE = 1,
    LAYER_GUTTER = 2,
    LAYER_ROOF = 3,
    LAYER_STEEL = 4,
    LAYER_WALL = 5,
    LAYER_WALL2 = 6,
    LAYER_WALL3 = 7,
    LAYER_OTHER = 8,
    LAYER_OTHER2 = 9,
    LAYER_OTHER3 = 10,
    LAYER_UNSET = 11
}LAYER_TYPE;

@interface LayerObject : NSObject
@property (nonatomic) LAYER_TYPE type;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *color;
@property (nonatomic) CMask *mask;
@property (nonatomic, strong) Color *colorValue;
@property (nonatomic, strong) NSString *patternImage;

@property (nonatomic, strong) NSString *feature;
@property (nonatomic, strong) NSString *gloss;
@property (nonatomic, strong) NSString *pattern;

@property (nonatomic, assign) int transparent;  //QuyPV Add
@end

typedef enum {
    ACTION_ADDMASK = 0,
    ACTION_DELETE = 1,
    ACTION_ADDAREA = 2,
    ACTION_SETCOLOR = 3,
    ACTION_SETTYPE = 4,
    ACTION_MOVE = 5,
    ACTION_ERASE_LAYERS = 6
}ACTION_TYPE;

@interface ActionObject : NSObject
@property (nonatomic) ACTION_TYPE action_type;
//@property (nonatomic) LAYER_TYPE layer_type;
//@property (nonatomic) LAYER_TYPE layer_type_post;
//@property (nonatomic, strong) Color *colorValue;
//@property (nonatomic, strong) Color *colorValue_post;
@property (nonatomic) int index;
@property (nonatomic) int index_post;
@end
