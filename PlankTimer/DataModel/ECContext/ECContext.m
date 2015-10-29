//
//  ECContext.m
//  ECarDriver
//
//  Created by sola on 15/8/24.
//  Copyright (c) 2015年 upluscar. All rights reserved.
//

#import "ECContext.h"
#import "STUtilities.h"
#import "ConstantVariables.h"
#import "TNCryptor.h"

@interface ECContext ()

@end

@implementation ECContext


+ (instancetype)sharedInstance {
    static ECContext* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ECContext new];
    });
    
    return instance;
}

@end
