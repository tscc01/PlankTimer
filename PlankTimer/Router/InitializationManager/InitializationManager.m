//
//  InitializationManager.m
//  TengNiu
//
//  Created by 李晓春 on 15/4/9.
//  Copyright (c) 2015年 Teng Niu. All rights reserved.
//

#import "InitializationManager.h"

@interface InitializationManager ()

@end

@implementation InitializationManager

+ (instancetype)sharedInstance {
    static InitializationManager* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [InitializationManager new];
    });
    
    return instance;
}

- (void)initSystemComponentsWithOptions:(NSDictionary *)launchOptions
{
}


- (void)registerRemoteNotification {
    
}
@end
