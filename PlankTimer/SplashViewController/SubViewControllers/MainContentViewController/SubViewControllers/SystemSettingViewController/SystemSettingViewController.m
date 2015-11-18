//
//  SystemSettingViewController.m
//  PlankTimer
//
//  Created by 李晓春 on 15/10/28.
//  Copyright © 2015年 tscc-sola. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "STUtilities.h"
#import "TextFieldWithTipTableViewCell.h"
#import "ConstantVariables.h"

@interface SystemSettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayCells;

@property (strong, nonatomic) NSMutableDictionary *dicSetting;

@property (strong, nonatomic) TextFieldWithTipTableViewCell *cellCount;
@property (strong, nonatomic) TextFieldWithTipTableViewCell *cellWorking;
@property (strong, nonatomic) TextFieldWithTipTableViewCell *cellRest;

@end

@implementation SystemSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    // Do any additional setup after loading the view from its nib.
    if ([[[PersistentHelper sharedInstance]getNumberForKey:IS_USER_HAS_SETTING]boolValue]) {
        [self loadUesrSetting];
    }
    else {
        [self loadDefaultSetting];
    }
    
    [self initCells];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"global_message_done", @"完成") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initCells
{
    _arrayCells = [NSMutableArray array];
    
    TextFieldWithTipTableViewCell *cellCount = [TextFieldWithTipTableViewCell viewFromNib];
    cellCount.labelInfo.text = @"进行次数";
    cellCount.textValue.text = _dicSetting[@"Count"];
    cellCount.textValue.keyboardType = UIKeyboardTypeNumberPad;
    _cellCount = cellCount;
    [_arrayCells addObject:cellCount];
    
    TextFieldWithTipTableViewCell *cellWorking = [TextFieldWithTipTableViewCell viewFromNib];
    cellWorking.labelInfo.text = @"撑举时间";
    cellWorking.textValue.text = _dicSetting[@"Working"];
    cellWorking.textValue.keyboardType = UIKeyboardTypeNumberPad;
    _cellWorking = cellWorking;
    [_arrayCells addObject:cellWorking];
    
    TextFieldWithTipTableViewCell *cellRest = [TextFieldWithTipTableViewCell viewFromNib];
    cellRest.labelInfo.text = @"休息时间";
    cellRest.textValue.text = _dicSetting[@"Rest"];
    cellRest.textValue.keyboardType = UIKeyboardTypeNumberPad;
    _cellRest = cellRest;
    [_arrayCells addObject:cellRest];
}

- (void)rightBarButtonAction:(id)sender
{
    if (![_cellCount.textValue.text intValue] || ![_cellWorking.textValue.text intValue] || ![_cellRest.textValue.text intValue]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请填充完整的设置" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([_cellWorking.textValue.text intValue] < 3) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"最少撑举3秒" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([_cellRest.textValue.text intValue] < 3) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"最少休息3秒" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[PersistentHelper sharedInstance]saveString:_cellCount.textValue.text forKey:USER_SETTING_COUNT];
    [[PersistentHelper sharedInstance]saveString:_cellWorking.textValue.text forKey:USER_SETTING_WORKING];
    [[PersistentHelper sharedInstance]saveString:_cellRest.textValue.text forKey:USER_SETTING_REST];
    
    [[PersistentHelper sharedInstance]saveNumber:[NSNumber numberWithBool:YES] forKey:IS_USER_HAS_SETTING];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadDefaultSetting
{
    _dicSetting = [NSMutableDictionary dictionary];
    _dicSetting[@"Count"] = @"8";
    _dicSetting[@"Working"] = @"20";
    _dicSetting[@"Rest"] = @"10";
}

- (void)loadUesrSetting
{
    _dicSetting = [NSMutableDictionary dictionary];
    _dicSetting[@"Count"] = [[PersistentHelper sharedInstance]getStringForKey:USER_SETTING_COUNT];
    _dicSetting[@"Working"] = [[PersistentHelper sharedInstance]getStringForKey:USER_SETTING_WORKING];
    _dicSetting[@"Rest"] = [[PersistentHelper sharedInstance]getStringForKey:USER_SETTING_REST];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _arrayCells[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}


@end

