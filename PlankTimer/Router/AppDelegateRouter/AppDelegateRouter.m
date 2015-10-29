//
//  AppDelegateRouter.m
//  TengNiu
//
//  Created by 李晓春 on 15/4/16.
//  Copyright (c) 2015年 Teng Niu. All rights reserved.
//

#import "AppDelegateRouter.h"
#import "ECContext.h"
#import "STUtilities.h"
#import "JSONKit.h"
#import "ConstantVariables.h"

@interface AppDelegateRouter ()


@end

@implementation AppDelegateRouter

+ (instancetype)sharedInstance {
    static AppDelegateRouter* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AppDelegateRouter new];
    });
    return instance;
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

}

@end
