//
//  SplashViewController.m
//  ECarDriver
//
//  Created by sola on 15/8/18.
//  Copyright (c) 2015年 upluscar. All rights reserved.
//

#import "SplashViewController.h"
#import "MainContentViewController.h"

@interface SplashViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSDictionary* dicVersion;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showContentViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showContentViewController
{
    MainContentViewController *vcContent = [[MainContentViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vcContent];
    [[UIApplication sharedApplication]delegate].window.rootViewController = navigationController;
}

@end
