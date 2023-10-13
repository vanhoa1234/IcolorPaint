//
//  HouseTemplateViewController.m
//  Decorator
//
//  Created by Le Hoang on 2/22/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "HouseTemplateViewController.h"

@interface HouseTemplateViewController (){
    CGRect frame;
    LayerObject *layer;
    NSMutableArray *templates;
    
}

@end

@implementation HouseTemplateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFrame:(CGRect)_frame andLayer:(LayerObject *)_layer{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        layer = [[LayerObject alloc] init];
        layer.type = _layer.type;
        layer.image = _layer.image;
        layer.name = _layer.name;
        layer.color = _layer.color;
        layer.colorValue = _layer.colorValue;
        layer.patternImage = _layer.patternImage;
        layer.feature = _layer.feature;
        layer.gloss = _layer.gloss;
        layer.pattern = _layer.pattern;
        frame = _frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer{
    self = [super init];
    if (self) {
        //        layer = _layer;
        layer = [[LayerObject alloc] init];
        layer.type = _layer.type;
        layer.image = _layer.image;
        layer.name = _layer.name;
        layer.color = _layer.color;
        layer.colorValue = _layer.colorValue;
        layer.patternImage = _layer.patternImage;
        layer.feature = _layer.feature;
        layer.gloss = _layer.gloss;
        layer.pattern = _layer.pattern;
        frame = _frame;
    }
    return self;
}

- (IBAction)dismissView:(id)sender {
    [_delegate dismissHouseTemplateViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = frame;
    _bt_cancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _bt_cancel.layer.borderWidth = 6.0f;
    templates = [NSMutableArray array];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"HouseTemplate" ofType:@"plist"];
    NSArray *content = [[NSArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:plistPath]];
    for (NSDictionary *dictionary in content) {
        HouseTemplate *hTemplate = [[HouseTemplate alloc] init];
        
        hTemplate.roofCode = [[dictionary objectForKey:@"roofColor"] objectForKey:@"Code"];
        hTemplate.roofR = [[[dictionary objectForKey:@"roofColor"] objectForKey:@"R"] intValue];
        hTemplate.roofG = [[[dictionary objectForKey:@"roofColor"] objectForKey:@"G"] intValue];
        hTemplate.roofB = [[[dictionary objectForKey:@"roofColor"] objectForKey:@"B"] intValue];
        
        hTemplate.wall1Code = [[dictionary objectForKey:@"wall1Color"] objectForKey:@"Code"];
        hTemplate.wall1R = [[[dictionary objectForKey:@"wall1Color"] objectForKey:@"R"] intValue];
        hTemplate.wall1G = [[[dictionary objectForKey:@"wall1Color"] objectForKey:@"G"] intValue];
        hTemplate.wall1B = [[[dictionary objectForKey:@"wall1Color"] objectForKey:@"B"] intValue];
        
        hTemplate.wall2Code = [[dictionary objectForKey:@"wall2Color"] objectForKey:@"Code"];
        hTemplate.wall2R = [[[dictionary objectForKey:@"wall2Color"] objectForKey:@"R"] intValue];
        hTemplate.wall2G = [[[dictionary objectForKey:@"wall2Color"] objectForKey:@"G"] intValue];
        hTemplate.wall2B = [[[dictionary objectForKey:@"wall2Color"] objectForKey:@"B"] intValue];
        
        hTemplate.pipeCode = [[dictionary objectForKey:@"pipeColor"] objectForKey:@"Code"];
        hTemplate.pipeR = [[[dictionary objectForKey:@"pipeColor"] objectForKey:@"R"] intValue];
        hTemplate.pipeG = [[[dictionary objectForKey:@"pipeColor"] objectForKey:@"G"] intValue];
        hTemplate.pipeB = [[[dictionary objectForKey:@"pipeColor"] objectForKey:@"B"] intValue];
        [templates addObject:hTemplate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedTemplate:(id)sender {
    HouseTemplate *selectedTemplate = [templates objectAtIndex:[(UIButton *)sender tag]-1];
    [_delegate selectedHouseTemplate:selectedTemplate];
}

@end
