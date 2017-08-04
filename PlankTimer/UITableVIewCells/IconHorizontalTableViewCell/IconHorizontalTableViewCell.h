//
//  IconHorizontalTableViewCell.h
//  HaoYa
//
//  Created by 李晓春 on 15/4/9.
//  Copyright (c) 2015年 HaoYa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconHorizontalTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewLeftConstraint;

@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgValue;

@end
