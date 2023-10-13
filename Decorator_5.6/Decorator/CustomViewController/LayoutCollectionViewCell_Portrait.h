//
//  LayoutCollectionViewCell_Portrait.h
//  Decorator
//
//  Created by Le Hoang on 6/24/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"
@interface LayoutCollectionViewCell_Portrait : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *planImageView;
@property (weak, nonatomic) IBOutlet UIButton *bt_applyPlan;
@property (weak, nonatomic) IBOutlet UILabel *lb_planName;
@property (weak, nonatomic) IBOutlet THLabel *lb_original;
@end
