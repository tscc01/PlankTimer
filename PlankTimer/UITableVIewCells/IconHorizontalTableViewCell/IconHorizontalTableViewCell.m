//
//  IconHorizontalTableViewCell.m
//  HaoYa
//
//  Created by 李晓春 on 15/4/9.
//  Copyright (c) 2015年 HaoYa. All rights reserved.
//

#import "IconHorizontalTableViewCell.h"
#import "STUtilities.h"

@interface IconHorizontalTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTail;

@end

@implementation IconHorizontalTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    if (self.accessoryType == UITableViewCellAccessoryNone) {
        _lcTail.constant = 15;
    } else {
        _lcTail.constant = 0;
    }
    [super layoutSubviews];
}

@end
