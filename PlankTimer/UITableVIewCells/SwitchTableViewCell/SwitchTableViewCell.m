//
//  SwitchTableViewCell.m
//  TengNiu
//
//  Created by 李晓春 on 15/4/8.
//  Copyright (c) 2015年 Teng Niu. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onSwitchClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(switchHasBeenClicked:)]) {
        [_delegate switchHasBeenClicked:sender];
    }
}

@end
