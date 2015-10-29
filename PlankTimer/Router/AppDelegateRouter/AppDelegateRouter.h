//
//  AppDelegateRouter.h
//  TengNiu
//
//  Created by 李晓春 on 15/4/16.
//  Copyright (c) 2015年 Teng Niu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppDelegateRouter : NSObject //<BPushDelegate>

+ (instancetype)sharedInstance;

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
