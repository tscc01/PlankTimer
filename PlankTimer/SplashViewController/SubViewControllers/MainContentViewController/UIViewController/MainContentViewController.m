//
//  MainContentViewController.m
//  ECarDriver
//
//  Created by sola on 15/8/18.
//  Copyright (c) 2015年 upluscar. All rights reserved.
//

#import "MainContentViewController.h"
#import "STUtilities.h"
#import "ConstantVariables.h"
#import "TimeLineView.h"
//#import "ECContext.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SystemSettingViewController.h"
#import <AVFoundation/AVFoundation.h>

enum {
    STATUS_STOP = 0,
    STATUS_START = 1,
    STATUS_WORKING = 2,
    STATUS_REST = 3,
};

@interface MainContentViewController ()
{
    BOOL m_bInWorking;
    BOOL m_bDuringAction;
    int m_nStatus;
    int m_nCounter;
    int m_nTimer;
}

@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnMain;

@property (strong, nonatomic) NSMutableDictionary *dicSetting;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (strong, nonatomic) UIView *viewAlpha;

@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation MainContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"挑战";
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"global_setting", @"设置") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//- (void)leftBarButtonAction:(id)sender
//{
//    [[ECContext sharedInstance].sideMenu presentLeftMenuViewController];
//}

- (void)initViews
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [self.view layoutIfNeeded];
    
    [self clearViews];
    
    if ([[[PersistentHelper sharedInstance]getNumberForKey:IS_USER_HAS_SETTING]boolValue]) {
        [self loadUesrSetting];
    }
    else {
        [self loadDefaultSetting];
    }
    
    _labelInfo.text = @"点击开始来锻炼~";
    
    int nCount = [_dicSetting[@"Count"]intValue];
    int nWorking = [_dicSetting[@"Working"]intValue];
    int nRest = [_dicSetting[@"Rest"]intValue];
    CGFloat fWidth = _viewMain.frame.size.width / (nCount - 1 + 1.0 * nWorking / (nWorking + nRest));
    CGFloat fHeight = _viewMain.frame.size.height;
    CGFloat fLeftWidth = fWidth * (1.0 * nWorking / (nWorking + nRest));
    for (int i = 0; i < nCount; i++) {
        TimeLineView *view = [TimeLineView viewFromNib];
        view.frame = CGRectMake(fWidth * i, 0, fWidth, fHeight);
        view.lcLeftWidth.constant = fLeftWidth;
        if (i == nCount - 1) {
            view.lineTail.hidden = YES;
            view.lineBottom.hidden = YES;
            view.lineMid.hidden = YES;
        }
        [view layoutIfNeeded];
        [_viewMain addSubview:view];
    }
    
    _viewAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _viewMain.frame.size.width, _viewMain.frame.size.height)];
    _viewAlpha.backgroundColor = [UIColor redColor];
    _viewAlpha.hidden = YES;
    [_viewMain addSubview:_viewAlpha];
}

- (void)clearViews
{
    NSArray *array = _viewMain.subviews;
    NSInteger nCount = array.count;
    for (NSInteger i = nCount - 1; i >= 0; i--) {
        UIView *view = array[i];
        [view removeFromSuperview];
    }
}

- (void)resetViews
{
    [self initViews];
}

- (void)rightBarButtonAction:(id)sender
{
    SystemSettingViewController *viewController = [[SystemSettingViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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


- (void)startWork
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    m_nStatus = STATUS_START;
    _labelInfo.text = @"准备~";
    _viewAlpha.hidden = NO;
    _viewAlpha.alpha = 1;
    _viewAlpha.backgroundColor = [UIColor redColor];
    [self playReady];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (m_nStatus == STATUS_STOP) {
            m_bDuringAction = NO;
            return;
        }
        _labelInfo.text = @"开始！";
        _viewAlpha.alpha = 1;
        _viewAlpha.backgroundColor = [UIColor greenColor];
        [self playReady];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (m_nStatus == STATUS_STOP) {
                m_bDuringAction = NO;
                return;
            }
            int nWorking = [_dicSetting[@"Working"]intValue];
            m_nTimer = nWorking;
            m_nCounter = 0;
            m_nStatus = STATUS_WORKING;
            _viewAlpha.alpha = 0.5;
            _viewAlpha.backgroundColor = [UIColor blackColor];
            [self playStart];
            [self startAnimation];
        });
    });
}

- (void)startAnimation
{
    _labelInfo.text = [NSString stringWithFormat:@"%d", m_nTimer];

    [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        int nCount = [_dicSetting[@"Count"]intValue];
        int nWorking = [_dicSetting[@"Working"]intValue];
        int nRest = [_dicSetting[@"Rest"]intValue];
        m_nTimer--;
        if (m_nTimer == 2 || m_nTimer == 1) {
            [self playReady];
        }
        if (m_nTimer == 0) {
            switch (m_nStatus) {
                case STATUS_WORKING:
                    if (m_nCounter == nCount - 1) {
                        [self playStop];

                        m_nStatus = STATUS_STOP;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self finishAnimation];
                        });
                        m_nTimer = 0;
                    }
                    else {
                        [self playStart];
                        m_nStatus = STATUS_REST;
                        m_nTimer = nRest;
                    }
                    break;
                case STATUS_REST:
                    [self playStart];
                    m_nCounter++;
                    m_nStatus = STATUS_WORKING;
                    m_nTimer = nWorking;
                    break;
                default:
                    [self playStart];
                    break;
            }
        }
        CGFloat fWidth = _viewMain.frame.size.width / (nCount - 1 + 1.0 * nWorking / (nWorking + nRest));
        CGRect rect = CGRectMake(0, 0, _viewMain.frame.size.width, _viewMain.frame.size.height);
        CGFloat fMinus = fWidth * m_nCounter;
        if (m_nStatus == STATUS_WORKING) {
            fMinus += fWidth * (nWorking - m_nTimer) / (nWorking + nRest);
        }
        else if (m_nStatus == STATUS_STOP) {
            fMinus = _viewMain.frame.size.width;
        }
        else {
            fMinus += fWidth * nWorking / (nWorking + nRest);
            fMinus += fWidth * (nRest - m_nTimer) / (nWorking + nRest);
        }
        rect.size.width -= fMinus;
        rect.origin.x += fMinus;
        _viewAlpha.frame = rect;
    } completion:^(BOOL finished) {
        if (m_nStatus == STATUS_STOP) {
            m_bDuringAction = NO;
            return;
        }
        [self startAnimation];
    }];
}

- (void)finishAnimation
{
    [self resetViews];
}

- (void)stopWork
{
    switch (m_nStatus) {
        case STATUS_STOP:
            m_bDuringAction = NO;
            break;
        case STATUS_START:
            m_nStatus = STATUS_STOP;
            break;
        case STATUS_WORKING:
            m_nStatus = STATUS_STOP;
            break;
        case STATUS_REST:
            m_nStatus = STATUS_STOP;
            break;
        default:
            m_nStatus = STATUS_STOP;
            break;
    }
}

- (IBAction)onButtonMainClicked:(id)sender {
    if (m_bDuringAction) {
        return;
    }
    
    m_bInWorking = !m_bInWorking;
    if (m_bInWorking) {
        [[BasicUtility sharedInstance]setButton:_btnMain titleForAllState:@"暂停"];
        [self startWork];
    }
    else {
        [[BasicUtility sharedInstance]setButton:_btnMain titleForAllState:@"开始"];
        m_bDuringAction = YES;
        [self stopWork];
        [self resetViews];
    }
}

- (void)playReady
{
    NSString *strPath = [[NSBundle mainBundle]pathForResource:@"beep1" ofType:@"mp3"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strPath] error:nil];
    _player = player;
    [player play];
}

- (void)playStart
{
    NSString *strPath = [[NSBundle mainBundle]pathForResource:@"beep2" ofType:@"mp3"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strPath] error:nil];
    _player = player;
    [player play];
}

- (void)playStop
{
    NSString *strPath = [[NSBundle mainBundle]pathForResource:@"beep2" ofType:@"mp3"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strPath] error:nil];
    player.numberOfLoops = 2;
    _player = player;
    [player play];
}

@end
