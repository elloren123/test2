//
//  ADLTextFieldView.m
//  lockboss
//
//  Created by Adel on 2019/11/13.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLTextFieldView.h"
#import "ADLSelectNationView.h"
#import "ADLAccHistoryView.h"
#import "ADLGlobalDefine.h"
#import "ADLUtils.h"

@interface ADLTextFieldView ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) ADLTextFieldType type;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *pullBtn;
@property (nonatomic, strong) UIButton *codeBtn;
@property (nonatomic, strong) UILabel *areaLab;
@property (nonatomic, assign) NSInteger hisNum;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger time;
@end

@implementation ADLTextFieldView

- (instancetype)initWithFrame:(CGRect)frame type:(ADLTextFieldType)type {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        CGFloat wid = self.frame.size.width;
        CGFloat hei = self.frame.size.height;
        
        UITextField *textField = [[UITextField alloc] init];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.font = [UIFont systemFontOfSize:FONT_SIZE];
        textField.returnKeyType = UIReturnKeyDone;
        textField.textColor = COLOR_333333;
        textField.delegate = self;
        self.textField = textField;
        
        if (type == ADLTextFieldTypePhone) {
            _history = YES;
            NSDictionary *dict = @{@"en":@"China", @"zh-Hant":@"中國大陸", @"zh-Hans":@"中国大陆"};
            self.nationName = dict[[ADLLocalizedHelper helper].currentLanguage];
            self.nationCode = @"86";
            
            UIView *areaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, hei)];
            areaView.layer.borderColor= COLOR_D3D3D3.CGColor;
            areaView.layer.cornerRadius = CORNER_RADIUS;
            areaView.layer.borderWidth = 0.5;
            [self addSubview:areaView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAreaView)];
            [areaView addGestureRecognizer:tap];
            
            CGFloat areaW = [ADLUtils calculateString:@"+86" rectSize:CGSizeMake(70, hei) fontSize:13].width+15;
            UILabel *areaLab = [[UILabel alloc] initWithFrame:CGRectMake(36-areaW/2, 0, areaW-13, hei)];
            areaLab.font = [UIFont systemFontOfSize:13];
            areaLab.textColor = COLOR_333333;
            areaLab.text = @"+86";
            [areaView addSubview:areaLab];
            self.areaLab = areaLab;
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(24+areaW/2, (hei-2)/2, 8, 4)];
            imgView.image = [UIImage imageNamed:@"login_trai"];
            [areaView addSubview:imgView];
            self.imgView = imgView;
            
            UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(80, 0, wid-80, hei)];
            phoneView.layer.borderColor = COLOR_D3D3D3.CGColor;
            phoneView.layer.cornerRadius = CORNER_RADIUS;
            phoneView.layer.borderWidth = 0.5;
            [self addSubview:phoneView];
            
            NSString *phistory = [ADLUtils filePathWithName:HISTORY_PHONE permanent:YES];
            NSArray *phoneArr = [NSArray arrayWithContentsOfFile:phistory];
            self.hisNum = phoneArr.count;
            if (self.hisNum > 0) {
                textField.frame = CGRectMake(12, 0, wid-128, hei);
                self.pullBtn.frame = CGRectMake(wid-116, 0, 36, hei);
                [phoneView addSubview:self.pullBtn];
            } else {
                textField.frame = CGRectMake(12, 0, wid-97, hei);
            }
            
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = ADLString(@"ph_phone");
            [phoneView addSubview:textField];
            
        } else if (type == ADLTextFieldTypeCode) {
            UIView *codeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid-118, hei)];
            codeView.layer.borderColor = COLOR_D3D3D3.CGColor;
            codeView.layer.cornerRadius = CORNER_RADIUS;
            codeView.layer.borderWidth = 0.5;
            [self addSubview:codeView];
            
            UIButton *codeBtn = [[UIButton alloc] initWithFrame:CGRectMake(wid-108, 0, 108, hei)];
            [codeBtn addTarget:self action:@selector(clickGetCodeBtn) forControlEvents:UIControlEventTouchUpInside];
            [codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [codeBtn setTitle:ADLString(@"get_code") forState:UIControlStateNormal];
            codeBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
            codeBtn.layer.cornerRadius = CORNER_RADIUS;
            codeBtn.backgroundColor = APP_COLOR;
            [self addSubview:codeBtn];
            self.codeBtn = codeBtn;
            
            textField.frame = CGRectMake(12, 0, wid-135, hei);
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = ADLString(@"ph_code");
            [codeView addSubview:textField];
            
        } else if (type == ADLTextFieldTypePwd) {
            UIView *pwdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, hei)];
            pwdView.layer.borderColor = COLOR_D3D3D3.CGColor;
            pwdView.layer.cornerRadius = CORNER_RADIUS;
            pwdView.layer.borderWidth = 0.5;
            [self addSubview:pwdView];
            
            UIButton *showBtn = [[UIButton alloc] initWithFrame:CGRectMake(wid-44, 0, 44, hei)];
            [showBtn setImage:[UIImage imageNamed:@"login_hide"] forState:UIControlStateNormal];
            [showBtn setImage:[UIImage imageNamed:@"login_show"] forState:UIControlStateSelected];
            [showBtn addTarget:self action:@selector(clickShowPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
            [pwdView addSubview:showBtn];
            
            textField.frame = CGRectMake(12, 0, wid-56, hei);
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.placeholder = ADLString(@"ph_pwd");
            textField.secureTextEntry = YES;
            if (@available(iOS 10.0, *)) {
                textField.textContentType = UITextContentTypeName;
            }
            [pwdView addSubview:textField];
            
        } else {
            _history = YES;
            UIView *emailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, hei)];
            emailView.layer.borderColor = COLOR_D3D3D3.CGColor;
            emailView.layer.cornerRadius = CORNER_RADIUS;
            emailView.layer.borderWidth = 0.5;
            [self addSubview:emailView];
            
            NSString *ehistory = [ADLUtils filePathWithName:HISTORY_EMAIL permanent:YES];
            NSArray *emailArr = [NSArray arrayWithContentsOfFile:ehistory];
            self.hisNum = emailArr.count;
            if (self.hisNum > 0) {
                textField.frame = CGRectMake(12, 0, wid-48, hei);
                self.pullBtn.frame = CGRectMake(wid-36, 0, 36, hei);
                [emailView addSubview:self.pullBtn];
            } else {
                textField.frame = CGRectMake(12, 0, wid-17, hei);
            }
            
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.placeholder = ADLString(@"ph_email");
            [emailView addSubview:textField];
        }
    }
    return self;
}

#pragma mark ------ UITextFieldDelegate ------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.type == ADLTextFieldTypePwd) {
        [ADLUtils dealWithSecureEntryWithTextField:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.type == ADLTextFieldTypePhone) {
        return [ADLUtils phoneTextField:textField replacementString:string];
    } else if (self.type == ADLTextFieldTypeCode) {
        return [ADLUtils numberTextField:textField replacementString:string maxLength:6 firstZero:YES];
    } else if (self.type == ADLTextFieldTypePwd) {
        return [ADLUtils limitedTextField:textField replacementString:string maxLength:18];
    } else {
        return YES;
    }
}

#pragma mark ------ 选择手机区号 ------
- (void)clickAreaView {
    if (self.willShowView) {
        self.willShowView();
    }
    [ADLSelectNationView showWithFinish:^(NSDictionary *dict) {
        if (![dict[@"code"] isEqualToString:self.areaLab.text]) {
            self.areaLab.text = dict[@"code"];
            CGFloat hei = self.frame.size.height;
            self.nationCode = [self.areaLab.text substringFromIndex:1];
            self.nationName = dict[[ADLLocalizedHelper helper].currentLanguage];
            CGFloat areaW = [ADLUtils calculateString:dict[@"code"] rectSize:CGSizeMake(70, hei) fontSize:13].width+15;
            self.areaLab.frame = CGRectMake(36-areaW/2, 0, areaW-13, hei);
            self.imgView.frame = CGRectMake(24+areaW/2, (hei-2)/2, 8, 4);
        }
    }];
}

#pragma mark ------ 获取验证码 ------
- (void)clickGetCodeBtn {
    if (self.clickGetCode) {
        self.clickGetCode();
    }
}

#pragma mark ------ 显示隐藏密码 ------
- (void)clickShowPwdBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.textField.secureTextEntry = NO;
    } else {
        self.textField.secureTextEntry = YES;
    }
    [ADLUtils dealWithSecureEntryWithTextField:self.textField];
}

#pragma mark ------ 点击历史记录 ------
- (void)clickPullBtn {
    if (self.willShowView) {
        self.willShowView();
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.pullBtn.transform = CGAffineTransformMakeRotation(M_PI);
    }];
    
    CGRect frame = self.frame;
    frame.origin.y = self.frame.origin.y+self.frame.size.height+8;
    frame.size.height = SCREEN_HEIGHT-self.frame.origin.y-self.frame.size.height-26;
    BOOL phone = self.type == ADLTextFieldTypePhone ? YES : NO;
    [ADLAccHistoryView showWithFrame:frame phone:phone change:^(NSInteger num) {
        self.hisNum = num;
        if (num == 0) {
            self.pullBtn.hidden = YES;
            if (phone) {
                self.textField.frame = CGRectMake(12, 0, self.frame.size.width-97, self.frame.size.height);
            } else {
                self.textField.frame = CGRectMake(12, 0, self.frame.size.width-17, self.frame.size.height);
            }
        }
    } finish:^(NSString *account) {
        if (account.length > 0) {
            self.textField.text = account;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.pullBtn.transform = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark ------ 验证码倒计时 ------
- (void)startUpdateTimer {
    self.time = 60;
    self.codeBtn.enabled = NO;
    [self.textField becomeFirstResponder];
    [self.codeBtn setTitle:@"60s" forState:UIControlStateNormal];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

#pragma mark ------ 更新验证码 ------
- (void)updateTime {
    self.time--;
    if (self.time == 0) {
        [self.timer invalidate];
        self.codeBtn.enabled = YES;
        [self.codeBtn setTitle:ADLString(@"get_code") forState:UIControlStateNormal];
    } else {
        [self.codeBtn setTitle:[NSString stringWithFormat:@"%lus",self.time] forState:UIControlStateNormal];
    }
}

#pragma mark ------ 开始输入 ------
- (void)beginInputing {
    [self.textField becomeFirstResponder];
}

#pragma mark ------ 结束输入 ------
- (void)endInputing {
    [self.textField resignFirstResponder];
}

#pragma mark ------ 是否正在输入 ------
- (BOOL)inputing {
    return [self.textField isFirstResponder];
}

#pragma mark ------ 获取textField内容 ------
- (NSString *)text {
    return self.textField.text;
}

#pragma mark ------ 历史记录 ------
- (void)setHistory:(BOOL)history {
    _history = history;
    CGFloat wid = self.frame.size.width;
    CGFloat hei = self.frame.size.height;
    
    if (history && self.hisNum > 0) {
        self.pullBtn.hidden = NO;
        if (self.type == ADLTextFieldTypePhone) {
            self.textField.frame = CGRectMake(12, 0, wid-128, hei);
            self.pullBtn.frame = CGRectMake(wid-116, 0, 36, hei);
        } else {
            self.textField.frame = CGRectMake(12, 0, wid-48, hei);
            self.pullBtn.frame = CGRectMake(wid-36, 0, 36, hei);
        }
    } else {
        self.pullBtn.hidden = YES;
        if (self.type == ADLTextFieldTypePhone) {
            self.textField.frame = CGRectMake(12, 0, wid-97, hei);
        } else {
            self.textField.frame = CGRectMake(12, 0, wid-17, hei);
        }
    }
}

#pragma mark ------ Placeholder ------
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textField.placeholder = placeholder;
}

#pragma mark ------ 销毁Timer ------
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark ------ 懒加载 ------
- (UIButton *)pullBtn {
    if (_pullBtn == nil) {
        _pullBtn = [[UIButton alloc] init];
        [_pullBtn setImage:[UIImage imageNamed:@"pull_down"] forState:UIControlStateNormal];
        [_pullBtn addTarget:self action:@selector(clickPullBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pullBtn;
}

@end
