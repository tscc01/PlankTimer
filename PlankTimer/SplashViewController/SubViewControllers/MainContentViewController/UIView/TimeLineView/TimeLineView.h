//
//  TimeLineView.h
//  PlankTimer
//
//  Created by 李晓春 on 15/10/28.
//  Copyright © 2015年 tscc-sola. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcLeftWidth;

@property (weak, nonatomic) IBOutlet UIView *lineTail;
@property (weak, nonatomic) IBOutlet UIView *lineMid;
@property (weak, nonatomic) IBOutlet UIView *lineBottom;

@end
