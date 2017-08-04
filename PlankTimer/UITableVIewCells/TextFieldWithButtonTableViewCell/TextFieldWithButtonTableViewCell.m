//
//  TextFieldCellWithButtonTableViewCell.m
//  HaoYa
//
//  Created by 李晓春 on 15/4/10.
//  Copyright (c) 2015年 HaoYa. All rights reserved.
//

#import "TextFieldWithButtonTableViewCell.h"

@implementation TextFieldWithButtonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    _btnAction.layer.borderColor = self.btnAction.tintColor.CGColor;
    _btnAction.layer.borderWidth = 1;
    _btnAction.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
