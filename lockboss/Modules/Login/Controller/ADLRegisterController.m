//
//  ADLRegisterController.m
//  lockboss
//
//  Created by adel on 2019/4/17.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLRegisterController.h"
#import "ADLSuccessStatusController.h"
#import "ADLTextFieldView.h"

@interface ADLRegisterController ()
@property (nonatomic, strong) ADLTextFieldView *phoneView;
@property (nonatomic, strong) ADLTextFieldView *emailView;
@property (nonatomic, strong) ADLTextFieldView *codeView;
@property (nonatomic, strong) ADLTextFieldView *pwdView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UILabel *switchLab;
@end

@implementation ADLRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavigationView:ADLString(@"register")];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    ADLTextFieldView *phoneView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, NAVIGATION_H+20, SCREEN_WIDTH-60, 45) type:ADLTextFieldTypePhone];
    phoneView.backgroundColor = [UIColor whiteColor];
    phoneView.history = NO;
    self.phoneView = phoneView;
    
    ADLTextFieldView *emailView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, NAVIGATION_H+20, SCREEN_WIDTH-60, 45) type:ADLTextFieldTypeEmail];
    emailView.backgroundColor = [UIColor whiteColor];
    emailView.history = NO;
    emailView.hidden = YES;
    self.emailView = emailView;
    
    self.codeView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, NAVIGATION_H+77, SCREEN_WIDTH-60, 45) type:ADLTextFieldTypeCode];
    self.pwdView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, NAVIGATION_H+134, SCREEN_WIDTH-60, 45) type:ADLTextFieldTypePwd];
    
    [self.view addSubview:self.pwdView];
    [self.view addSubview:self.codeView];
    [self.view addSubview:phoneView];
    [self.view addSubview:emailView];
    
    CGFloat ptW = [ADLUtils calculateString:ADLString(@"register_pt") rectSize:CGSizeMake(MAXFLOAT, 20) fontSize:13].width+2;
    CGFloat adW = [ADLUtils calculateString:ADLString(@"and") rectSize:CGSizeMake(MAXFLOAT, 20) fontSize:13].width+2;
    CGFloat ppW = [ADLUtils calculateString:ADLString(@"register_pp") rectSize:CGSizeMake(MAXFLOAT, 20) fontSize:13].width+2;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H+236, SCREEN_WIDTH, 105)];
    contentView.clipsToBounds = YES;
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    submitBtn.frame = CGRectMake(30, 0, SCREEN_WIDTH-60, 44);
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn setTitle:ADLString(@"submit") forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    submitBtn.layer.cornerRadius = CORNER_RADIUS;
    submitBtn.backgroundColor = APP_COLOR;
    [submitBtn addTarget:self action:@selector(clickSubmitBtn) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:submitBtn];
    self.submitBtn = submitBtn;
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(29, 55, SCREEN_WIDTH-58, 20)];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.font = [UIFont systemFontOfSize:13];
    lab1.text = ADLString(@"register_aa");
    lab1.textColor = COLOR_999999;
    [contentView addSubview:lab1];
    
    UIButton *protocolBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    protocolBtn.frame = CGRectMake((SCREEN_WIDTH-ptW-adW-ppW)/2, 73, ptW, 30);
    [protocolBtn setTitle:ADLString(@"register_pt") forState:UIControlStateNormal];
    [protocolBtn setTitleColor:APP_COLOR forState:UIControlStateNormal];
    protocolBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [protocolBtn addTarget:self action:@selector(clickProtocolBtn) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:protocolBtn];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH+ptW-adW-ppW)/2, 73, adW, 30)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.font = [UIFont systemFontOfSize:13];
    lab2.textColor = COLOR_999999;
    lab2.text = ADLString(@"and");
    [contentView addSubview:lab2];
    
    UIButton *privacyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    privacyBtn.frame = CGRectMake((SCREEN_WIDTH+ptW+adW-ppW)/2, 73, ppW, 30);
    [privacyBtn setTitle:ADLString(@"register_pp") forState:UIControlStateNormal];
    [privacyBtn setTitleColor:APP_COLOR forState:UIControlStateNormal];
    privacyBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [privacyBtn addTarget:self action:@selector(clickPrivacyBtn) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:privacyBtn];
    
    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-44)/2, SCREEN_HEIGHT-BOTTOM_H-70, 44, 44)];
    [switchBtn setImage:[UIImage imageNamed:@"login_email"] forState:UIControlStateNormal];
    [switchBtn setImage:[UIImage imageNamed:@"login_phone"] forState:UIControlStateSelected];
    [switchBtn addTarget:self action:@selector(clickSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchBtn];
    
    UILabel *switchLab = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, SCREEN_HEIGHT-BOTTOM_H-106, 300, 36)];
    switchLab.font = [UIFont systemFontOfSize:FONT_SIZE];
    switchLab.textAlignment = NSTextAlignmentCenter;
    switchLab.text = ADLString(@"email");
    switchLab.textColor = COLOR_333333;
    [self.view addSubview:switchLab];
    self.switchLab = switchLab;
    
    __weak typeof(self)weakSelf = self;
    phoneView.willShowView = ^{
        [weakSelf.view endEditing:YES];
    };
    
    self.codeView.clickGetCode = ^{
        [weakSelf getMessageCode];
    };
}

#pragma mark ------ 获取验证码 ------
- (void)getMessageCode {
    if (self.phoneView.text.length == 0) {
        [ADLToast showMessage:ADLString(@"ph_phone")];
        return;
    }
    
    [ADLToast showLoadingMessage:ADLString(@"loading")];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@(0) forKey:@"type"];
    [params setValue:self.phoneView.text forKey:@"phone"];
    [params setValue:self.phoneView.nationCode forKey:@"nationCode"];
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    [ADLNetWorkManager postWithPath:ADEL_getCode parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            [ADLToast showMessage:ADLString(@"code_success")];
            [self.codeView startUpdateTimer];
        }
    } failure:nil];
}

#pragma mark ------ 切换方式 ------
- (void)clickSwitchBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if ([self.phoneView inputing]) {
            [self.phoneView endInputing];
        }
        if ([self.codeView inputing]) {
            [self.codeView endInputing];
        }
        self.emailView.hidden = NO;
        self.phoneView.hidden = YES;
        self.switchLab.text = ADLString(@"phone");
        
        [UIView animateWithDuration:0.5 animations:^{
            self.codeView.frame = CGRectMake(30, NAVIGATION_H+20, SCREEN_WIDTH-60, 45);
            self.pwdView.frame = CGRectMake(30, NAVIGATION_H+77, SCREEN_WIDTH-60, 45);
            self.contentView.frame = CGRectMake(0, NAVIGATION_H+179, SCREEN_WIDTH, 105);
        }];
    } else {
        if ([self.emailView inputing]) {
            [self.emailView endInputing];
        }
        self.phoneView.hidden = NO;
        self.emailView.hidden = YES;
        self.switchLab.text = ADLString(@"email");
        
        [UIView animateWithDuration:0.5 animations:^{
            self.codeView.frame = CGRectMake(30, NAVIGATION_H+77, SCREEN_WIDTH-60, 45);
            self.pwdView.frame = CGRectMake(30, NAVIGATION_H+134, SCREEN_WIDTH-60, 45);
            self.contentView.frame = CGRectMake(0, NAVIGATION_H+236, SCREEN_WIDTH, 105);
        }];
    }
}

#pragma mark ------ 提交 ------
- (void)clickSubmitBtn {
    if (self.phoneView.hidden) {
        if (self.emailView.text.length == 0) {
            [ADLToast showMessage:ADLString(@"ph_mail")];
            return;
        }
        if (![ADLUtils verifyEmailAddress:self.emailView.text]) {
            [ADLToast showMessage:ADLString(@"pp_mail")];
            return;
        }
    } else {
        if (self.phoneView.text.length == 0) {
            [ADLToast showMessage:ADLString(@"ph_phone")];
            return;
        }
        if (self.codeView.text.length != 6) {
            [ADLToast showMessage:ADLString(@"pp_code")];
            return;
        }
    }
    if (self.pwdView.text.length < 6) {
        [ADLToast showMessage:ADLString(@"ph_pwd")];
        return;
    }
    [self.view endEditing:YES];
    [ADLToast showLoadingMessage:ADLString(@"loading")];
    
    if (self.phoneView.hidden) {
        [self submitRegisterInfo];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:@(0) forKey:@"type"];
        [params setValue:self.phoneView.text forKey:@"phone"];
        [params setValue:self.phoneView.nationCode forKey:@"nationCode"];
        [params setValue:self.codeView.text forKey:@"messageVerificationCode"];
        [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
        [ADLNetWorkManager postWithPath:ADEL_verifyMessageVerificationCode parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
            if ([responseDict[@"code"] integerValue] == 10000) {
                [self submitRegisterInfo];
            }
        } failure:nil];
    }
}

#pragma mark ------ 提交注册请求 ------
- (void)submitRegisterInfo {
    NSString *path = ADEL_registerPhone;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (self.phoneView.hidden) {
        path = ADEL_email;
        [params setValue:self.emailView.text forKey:@"email"];
        [params setValue:[ADLUtils md5Encrypt:self.pwdView.text lower:YES] forKey:@"password"];
    } else {
        [params setValue:self.phoneView.text forKey:@"phone"];
        [params setValue:self.phoneView.nationCode forKey:@"nationCode"];
        [params setValue:self.phoneView.nationName forKey:@"nationName"];
        [params setValue:[ADLUtils md5Encrypt:self.pwdView.text lower:YES] forKey:@"password"];
    }
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    [ADLNetWorkManager postWithPath:path parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            [ADLToast hide];
            ADLSuccessStatusController *statusVC = [[ADLSuccessStatusController alloc] init];
            if (self.phoneView.hidden) {
                statusVC.type = ADLSuccessTypeRegisterEmail;
            } else {
                statusVC.type = ADLSuccessTypeRegisterPhone;
            }
            [self.navigationController pushViewController:statusVC animated:YES];
        }
    } failure:nil];
}

#pragma mark ------ 用户协议 ------
- (void)clickProtocolBtn {
    [ADLToast showMessage:@"用户协议"];
}

#pragma mark ------ 隐私政策 ------
- (void)clickPrivacyBtn {
    [ADLToast showMessage:@"隐私政策"];
}

#pragma mark ------ 退出键盘 ------
- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
