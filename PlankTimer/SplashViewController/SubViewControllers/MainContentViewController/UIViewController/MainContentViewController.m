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
#import <iAd/iAd.h>
#import "CERoundProgressView.h"


enum {
    STATUS_STOP = 0,
    STATUS_START = 1,
    STATUS_WORKING = 2,
    STATUS_REST = 3,
};

@interface MainContentViewController () <ADBannerViewDelegate, UIActionSheetDelegate>
{
    BOOL m_bInWorking;
    BOOL m_bDuringAction;
    int m_nStatus;
    int m_nCounter;
    int m_nTimer;
}

@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UIButton *btnMain;

@property (strong, nonatomic) NSMutableDictionary *dicSetting;
@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (strong, nonatomic) AVAudioPlayer *player;

@property (weak, nonatomic) IBOutlet ADBannerView *iAdBannerView;

@property (weak, nonatomic) IBOutlet CERoundProgressView *progressTimer;
@property (weak, nonatomic) IBOutlet CERoundProgressView *progressCounter;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation MainContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"挑战";
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"global_setting", @"设置") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _iAdBannerView.hidden = YES;
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
    [self initViews];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)initViews
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [self.view layoutIfNeeded];
    
    if ([[[PersistentHelper sharedInstance]getNumberForKey:IS_USER_HAS_SETTING]boolValue]) {
        [self loadUesrSetting];
    }
    else {
        [self loadDefaultSetting];
    }
    
    m_bInWorking = NO;
    [[BasicUtility sharedInstance]setButton:_btnMain titleForAllState:@"开始"];
    
    _labelInfo.text = @"点击开始来锻炼~";
    _labelTime.hidden = YES;
    
    [_progressTimer setProgress:0 animated:NO];
    [_progressCounter setProgress:0 animated:NO];
    [_progressTimer.layer removeAllAnimations];
    [_progressCounter.layer removeAllAnimations];

    _progressTimer.startAngle = 3 * M_PI_2;
    _progressTimer.startAngle = 3 * M_PI_2;

    _progressTimer.animationDuration = 1;
    _progressCounter.animationDuration = 1;
    
    _progressTimer.tintColor = [UIColor whiteColor];
    _progressTimer.trackColor = [UIColor colorWithHexValue:@"ff6633"];
    
    _progressCounter.tintColor = [UIColor whiteColor];
    _progressCounter.trackColor = [UIColor colorWithHexValue:@"0099ff"];
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
    
    _progressTimer.trackColor = [UIColor redColor];
    _progressCounter.trackColor = [UIColor redColor];
    
    [self playReady];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (m_nStatus == STATUS_STOP) {
            m_bDuringAction = NO;
            return;
        }
        _labelInfo.text = @"开始！";
        
        _progressTimer.trackColor = [UIColor greenColor];
        _progressCounter.trackColor = [UIColor greenColor];
        
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
            
            _progressTimer.trackColor = [UIColor colorWithHexValue:@"ff6633"];
            _progressCounter.trackColor = [UIColor colorWithHexValue:@"0099ff"];
            
            [self playStart];
            [self startAnimation];
        });
    });
}

- (void)startAnimation
{
    NSTimeInterval timeInterval =1.0 ;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    _timer = timer;
    [timer fire];
}

-(void)timerFired:(NSTimer*)theTimer
{
    if (m_nStatus == STATUS_STOP) {
        m_bDuringAction = NO;
        [theTimer invalidate];
        [self finishAnimation];
        return;
    }
    
    switch (m_nStatus) {
        case STATUS_WORKING:
            _progressTimer.trackColor = [UIColor colorWithHexValue:@"ff6633"];
            break;
        case STATUS_REST:
            _progressTimer.trackColor = [UIColor greenColor];
            break;
        default:
            _progressTimer.trackColor = [UIColor colorWithHexValue:@"ff6633"];
            break;
    }
    int nRestAlter = (m_nStatus == STATUS_REST)?1:0;
    _labelInfo.text = [NSString stringWithFormat:@"当前第%d组，还剩%d组", m_nCounter + 1 + nRestAlter, [_dicSetting[@"Count"]intValue] - m_nCounter - nRestAlter];
    _labelTime.text = [NSString stringWithFormat:@"%d", m_nTimer];
    _labelTime.hidden = NO;
    
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
                    [theTimer invalidate];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self setSuccess];
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
    else {
        switch (m_nStatus) {
            case STATUS_WORKING:
                if (m_nTimer + 1 == nWorking) {
                    _progressTimer.animationDuration = nWorking;
                    [_progressTimer setProgress:1.0 animated:YES];
                }
                
                break;
            case STATUS_REST:
                if (m_nTimer + 1 == nRest) {
                    _progressTimer.animationDuration = nRest;
                    [_progressTimer setProgress:1.0 animated:YES];
                }
                
                break;
            default:
                break;
        }
    }
    
    
    
    if (m_nTimer + 1 == nRest && m_nStatus == STATUS_REST) {
        [_progressCounter setProgress:1.0 * (m_nCounter + 1) / nCount animated:NO];
    }
    
    if (m_nTimer == nWorking && m_nStatus == STATUS_WORKING) {
        [_progressTimer setProgress:0 animated:NO];
    }
    else if (m_nTimer == nRest && m_nStatus == STATUS_REST) {
        [_progressTimer setProgress:0 animated:NO];
    }
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

- (void)setSuccess
{
    int nNumber = [[[PersistentHelper sharedInstance]getNumberForKey:USER_SUCCESS_COUNT]intValue];
    nNumber++;
    if (nNumber == USER_SUCCESS_AD_COUNT) {
        [self showAdView];
    }
    else {
        [[PersistentHelper sharedInstance]saveNumber:[NSNumber numberWithInt:nNumber] forKey:USER_SUCCESS_COUNT];
    }
}

- (void)showAdView
{
    NSString* strCancelTitle = @"你诚意不错，去看看";
    NSString* strFirstButtonTitle = @"没兴趣，别再烦我";
    NSString* strSecondButtonTitle = @"不高兴，下次再说";
    NSString* strThirdButtonTitle = @"程序还行，给个评论";
    
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"感谢您多次使用本APP健身，健身赚钱两不误，推荐您一款理财产品，最高年化收益率18%，有兴趣的话去看看吧~" delegate:self cancelButtonTitle:strCancelTitle destructiveButtonTitle:nil otherButtonTitles:strFirstButtonTitle, strSecondButtonTitle, strThirdButtonTitle, nil];
    
    [sheet showInView:self.view];
}


#pragma mark - ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    _iAdBannerView.hidden = NO;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[PersistentHelper sharedInstance]saveNumber:[NSNumber numberWithInt:(int)USER_SUCCESS_AD_COUNT] forKey:USER_SUCCESS_COUNT];
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [[PersistentHelper sharedInstance]saveNumber:[NSNumber numberWithInt:0] forKey:USER_SUCCESS_COUNT];
            break;
        case 2:
        {
            NSString* url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1053738418"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
            break;
        case 3:
        {
            NSString* url = [NSString stringWithFormat:@"http://dwz.cn/2fbTRc"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
            break;
            
        default:
            break;
    }
}


@end
