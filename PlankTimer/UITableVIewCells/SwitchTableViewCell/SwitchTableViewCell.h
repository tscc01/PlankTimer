//
//  SwitchTableViewCell.h
//  HaoYa
//
//  Created by 李晓春 on 15/4/8.
//  Copyright (c) 2015年 HaoYa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchTableViewCellDelegate <NSObject>
@optional

- (void)switchHasBeenClicked:(id)sender;

@end

@interface SwitchTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SwitchTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISwitch *switchValue;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcRight;

@end
