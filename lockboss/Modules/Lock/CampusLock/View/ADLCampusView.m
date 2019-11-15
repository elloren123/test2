//
//  ADLCampusView.m
//  lockboss
//
//  Created by Adel on 2019/8/27.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLCampusView.h"
#import "ADLToast.h"
#import "ADLNetWorkManager.h"
#import "ADLUtils.h"
#import "ADELUrlpath.h"
#import "ADLMyRoomCardController.h"
#import "ADLCUnlockRecordController.h"
#import "ADLDeviceRepairController.h"
#import "ADLNotificationsController.h"

@interface ADLCampusView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *unlockView;
@property (nonatomic, strong) UIImageView *lockView;
@property (nonatomic, strong) UILabel     *promptLab;
@property (nonatomic, strong) UIButton    *batteryBtn;
@property (nonatomic, strong) UILabel     *roomNumLab;
@property (nonatomic, strong) UILabel     *numberLab;
@property (nonatomic, strong) UIButton    *managerBtn;
@property (nonatomic, assign) BOOL        didGetDataFlag;
@property (nonatomic, strong) NSMutableDictionary  *campusDict;   //学生信息集合(包括设备信息)

@end

@implementation ADLCampusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self addNotifications];
    }
    return self;
}
- (void)setupView {
    self.didGetDataFlag = NO;
    self.campusDict = [NSMutableDictionary dictionary];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_H)];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_H+1);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    //下拉刷新
    __weak typeof(self)WeakSelf = self;
    scrollView.mj_header = [ADLRefreshHeader headerWithRefreshingBlock:^{
        WeakSelf.didGetDataFlag = NO;
        
        //下拉刷新
        [WeakSelf getCampusInfosShowLoadingMsgFlag:NO];
    }];
    
    
    //背景图片
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*2/3-NAVIGATION_H)];
    backView.image = [UIImage imageNamed:@"lock_home_bg"];
    [self.scrollView addSubview:backView];
    
    
    //************解锁图片************
    //白圈
    UIImageView *unlockView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-80, 50, 160, 160)];
    unlockView.image = [UIImage imageNamed:@"unlock_bg"];
    unlockView.userInteractionEnabled = YES;
    [self.scrollView addSubview:unlockView];
    self.unlockView = unlockView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUnlockImgview)];
    [unlockView addGestureRecognizer:tap];
    
    //当前锁的状态ImageView
    //锁的图片/打开的/关闭的
    UIImageView *lockView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-30, 95, 60, 60)];
    lockView.image = [UIImage imageNamed:@"lock_status"];
    [self.scrollView addSubview:lockView];
    self.lockView = lockView;
    
    //当前状态提示label
    //锁的打开和关闭/点击开锁,开锁中...,开锁成功,开锁失败
    UILabel *promptLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-40, 163, 80, 16)];
    promptLab.textAlignment = NSTextAlignmentCenter;
    promptLab.font = [UIFont boldSystemFontOfSize:12];
    promptLab.textColor = [UIColor whiteColor];
    promptLab.text = ADLString(@"tap_unlock");
    [self.scrollView addSubview:promptLab];
    self.promptLab = promptLab;
    
    
    //电池Button
    UIButton *batteryBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*2/3-100-NAVIGATION_H, SCREEN_WIDTH, 40)];
    batteryBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    batteryBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    [batteryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    batteryBtn.tag = 101;
    [self.scrollView addSubview:batteryBtn];
    [batteryBtn setImage:[UIImage imageNamed:@"battery_100"] forState:UIControlStateNormal];
    [batteryBtn setTitle:@"100%" forState:UIControlStateNormal];
    batteryBtn.hidden = YES;
    self.batteryBtn = batteryBtn;
    
    
    
    //************ btns ************
    UIImageView *btnBgView = [[UIImageView alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT*2/3-45-NAVIGATION_H, SCREEN_WIDTH-8, 90)];
    btnBgView.image = [UIImage imageNamed:@"bg_other_lock"];
    btnBgView.userInteractionEnabled = YES;
    [self.scrollView addSubview:btnBgView];
    
    for (int i = 0 ; i < 4; i++) {
        //电池Button
        UIButton *Btn = [[UIButton alloc] initWithFrame:CGRectMake(21+60*i+(SCREEN_WIDTH-290)*i/3, 7, 60, 80)];
        Btn.tag = 201+i;
        [Btn addTarget:self action:@selector(btnClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnBgView addSubview:Btn];
        
        
        UIImageView *btnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [Btn addSubview:btnImg];
        
        
        UILabel *btnLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 51, 60, 24)];
        btnLab.textAlignment = NSTextAlignmentCenter;
        btnLab.font = [UIFont systemFontOfSize:12.5];
        btnLab.textColor = [UIColor blackColor];
        [Btn addSubview:btnLab];
        
        if (0 == i) {
            btnImg.image = [UIImage imageNamed:@"icon_school_card"];
            btnLab.text  = @"门卡";
        } else if (1 == i) {
            btnImg.image = [UIImage imageNamed:@"icon_school_record"];
            btnLab.text  = @"开锁记录";
        } else if (2 == i) {
            btnImg.image = [UIImage imageNamed:@"icon_school_service"];
            btnLab.text  = @"设备报修";
        } else if (3 == i) {
            btnImg.image = [UIImage imageNamed:@"icon_school_message"];
            btnLab.text  = @"消息通知";
        }
    }
    
    
    
    
    //************ infosImgView ************
    UIImageView *InfoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT*2/3+40-NAVIGATION_H, SCREEN_WIDTH-8, SCREEN_HEIGHT/3-40)];
    InfoImgView.image = [UIImage imageNamed:@"bg_other_lock"];
    InfoImgView.userInteractionEnabled = YES;
    [self.scrollView addSubview:InfoImgView];
    
    
    UIImageView *proImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4-4, 5, SCREEN_WIDTH/2, 50)];
    proImgView.image = [UIImage imageNamed:@"icon_school_num"];
    [InfoImgView addSubview:proImgView];
    
    
    //'phone' Img
    UIImageView *phoneImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 15, 25, 25)];
    phoneImgView.image = [UIImage imageNamed:@"icon_school_phone"];
    phoneImgView.userInteractionEnabled = YES;
    [InfoImgView addSubview:phoneImgView];
    
    UITapGestureRecognizer *phonetap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPhoneImgView)];
    [phoneImgView addGestureRecognizer:phonetap];
    
    
    
    UILabel *roomLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4-4, 5, SCREEN_WIDTH/2, 50)];
    roomLab.textAlignment = NSTextAlignmentCenter;
    roomLab.font = [UIFont boldSystemFontOfSize:18];
    roomLab.textColor = [UIColor whiteColor];
    roomLab.text = @"---";
    [InfoImgView addSubview:roomLab];
    self.roomNumLab = roomLab;
    
    
    UILabel *numberLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH-8, SCREEN_HEIGHT/3-140-BOTTOM_H)];
    numberLab.textAlignment = NSTextAlignmentCenter;
    numberLab.font = [UIFont systemFontOfSize:14];
    numberLab.textColor = [UIColor blackColor];
    numberLab.text = @"人数: 0/0";
    [InfoImgView addSubview:numberLab];
    self.numberLab = numberLab;
    
    
    UIButton *manaBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/3-85-BOTTOM_H, SCREEN_WIDTH-8, 40)];
    manaBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    manaBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    [manaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [manaBtn setImage:[UIImage imageNamed:@"icon_school_admin"] forState:UIControlStateNormal];
    [manaBtn setTitle:@"管理员: --" forState:UIControlStateNormal];
    [InfoImgView addSubview:manaBtn];
    self.managerBtn = manaBtn;
}

#pragma mark ------ 按钮点击事件 ------
- (void)btnClickedAction:(UIButton *)sender {
    if ([self.campusDict[@"deviceId"] length] == 0) {
        [ADLToast showMessage:@"暂无设备"];
        return;
    }
    
    //跳转vc
    self.pushVCBlock(sender.tag);
}

#pragma mark ------ 手势识别 ------
- (void)startAnimation {
    self.unlockView.userInteractionEnabled = NO;
    self.promptLab.text = @"正在开锁...";
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(0.9);
    animation.toValue = @(1.1);
    animation.duration = 1;
    animation.autoreverses = YES;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.unlockView.layer addAnimation:animation forKey:@"scale"];
}
- (void)stopAnimation {
    self.unlockView.userInteractionEnabled = YES;
    self.lockView.image = [UIImage imageNamed:@"lock_status"];
    self.promptLab.text = @"点击开锁";
    [self.unlockView.layer removeAllAnimations];
}
- (void)clickUnlockImgview {
    if ([self.campusDict[@"deviceId"] length] == 0) {
        [ADLToast showMessage:@"暂无设备"];
        return;
        
    } else if ([self.campusDict[@"deviceStatus"] intValue] != 1) {
        [ADLToast showMessage:@"设备未上线"];
        return;
    }

    [self startAnimation];
    
    //延时5s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopAnimation];
    });
}
- (void)clickPhoneImgView {
    if ([self.campusDict[@"adminPhone"] length] == 0) {
        [ADLToast showMessage:@"暂无管理员信息"];
        return;
    }
}

#pragma mark ------ 添加/移除 通知 ------
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCampusInfos) name:@"GET_CAMPUS_INFO_NOTI" object:nil];
}
- (void)getCampusInfos {
    [self getCampusInfosShowLoadingMsgFlag:YES];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ------ 根据学生id 获取信息 - 用户版 ------
- (void)getCampusInfosShowLoadingMsgFlag:(BOOL)flag {
    if (self.didGetDataFlag) {//已获取过数据
        return;
    }
    
    if (flag) {
        [ADLToast showLoadingMessage:@"请稍后..."];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    
    ///网络请求
    [ADLNetWorkManager postWithPath:ADELMain_UrlCampus"/lockboss-school/client/student/info.do" parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([self.scrollView.mj_header isRefreshing]) {
            [self.scrollView.mj_header endRefreshing];
        }
        
        NSLog(@"获取学生信息返回: %@", responseDict);
        
        
        if ([responseDict[@"code"] intValue] == 10000) {    //成功
            [ADLToast hide];
            self.didGetDataFlag = YES;
            
            //获取到校园信息
            self.campusDict = [NSMutableDictionary dictionaryWithDictionary:responseDict[@"data"]];
            [self updateCampusInfos];
            
        } else {
            [ADLToast showMessage:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        NSLog(@"error ---> %@", error);
        
        if ([self.scrollView.mj_header isRefreshing]) {
            [self.scrollView.mj_header endRefreshing];
        }
    }];
}
- (void)updateCampusInfos {
    self.roomNumLab.text = self.campusDict[@"dormName"];
    self.numberLab.text  = [NSString stringWithFormat:@"人数: %@/%@", self.campusDict[@"inSum"], self.campusDict[@"bedSum"]];
    
    //管理员信息
    NSString *adminStr = @"管理员: 无";
    if ([self.campusDict[@"adminName"] length] != 0) {
        adminStr = [NSString stringWithFormat:@"管理员: %@", self.campusDict[@"adminName"]];
    }
    [self.managerBtn setTitle:adminStr forState:UIControlStateNormal];
    
    
    if ([self.campusDict[@"deviceStatus"] intValue] == 1) {//设备在线
        self.batteryBtn.hidden = NO;
        NSInteger percent = ([self.campusDict[@"battery"] integerValue]-4000)*100.0f/2400;
        if (percent < 0) percent = 0;
        if (percent > 100) percent = 100;
        [self.batteryBtn setTitle:[NSString stringWithFormat:@"%ld%%",percent] forState:UIControlStateNormal];
        if (percent < 20) {
            [self.batteryBtn setImage:[UIImage imageNamed:@"battery_20"] forState:UIControlStateNormal];
        } else if (percent < 40) {
            [self.batteryBtn setImage:[UIImage imageNamed:@"battery_40"] forState:UIControlStateNormal];
        } else if (percent < 60) {
            [self.batteryBtn setImage:[UIImage imageNamed:@"battery_60"] forState:UIControlStateNormal];
        } else if (percent < 80) {
            [self.batteryBtn setImage:[UIImage imageNamed:@"battery_80"] forState:UIControlStateNormal];
        } else {
            [self.batteryBtn setImage:[UIImage imageNamed:@"battery_100"] forState:UIControlStateNormal];
        }
    } else {
        self.batteryBtn.hidden = YES;
    }
}

@end

