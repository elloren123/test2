//
//  ADLLoginController.m
//  lockboss
//
//  Created by adel on 2019/4/16.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLLoginController.h"
#import "ADLRegisterController.h"
#import "ADLModifyPwdController.h"
#import "ADLBindOptionController.h"
#import "ADLTextFieldView.h"
#import "ADLRMQConnection.h"

#import "WXApi.h"
#import <AFNetworking.h>
#import <JMessage/JMSGUser.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface ADLLoginController ()<TencentSessionDelegate>
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) ADLTextFieldView *phoneView;
@property (nonatomic, strong) ADLTextFieldView *emailView;
@property (nonatomic, strong) ADLTextFieldView *codeView;
@property (nonatomic, strong) ADLTextFieldView *pwdView;
@property (nonatomic, strong) TencentOAuth *tcOAuth;
@property (nonatomic, strong) UIButton *phoneBtn;
@property (nonatomic, strong) UIButton *emailBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) CGFloat emailW;
@end

@implementation ADLLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*0.5)];
    imageView.image = [UIImage imageNamed:@"login_bg"];
    [self.view addSubview:imageView];
    
    CGFloat logoS = (SCREEN_WIDTH > 500 ? 100 : 70);
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-logoS)/2, (SCREEN_WIDTH*0.5-logoS)/2, logoS, logoS)];
    logoView.image = [UIImage imageNamed:@"login_logo"];
    [self.view addSubview:logoView];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, STATUS_HEIGHT, NAV_H, NAV_H)];
    [backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 38-NAV_H, 0, 0);
    [backBtn setAdjustsImageWhenHighlighted:NO];
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    CGFloat logoF = (SCREEN_WIDTH > 500 ? 17 : 12);
    UILabel *logoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/4+logoS/2+4, SCREEN_WIDTH, 26)];
    logoLab.text = @"LOCK BOSS";
    logoLab.font = [UIFont systemFontOfSize:logoF];
    logoLab.textColor = [UIColor whiteColor];
    logoLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:logoLab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    ADLTextFieldView *phoneView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, SCREEN_WIDTH*0.5+30, SCREEN_WIDTH-60, VIEW_HEIGHT) type:ADLTextFieldTypePhone];
    [self.view addSubview:phoneView];
    self.phoneView = phoneView;
    
    ADLTextFieldView *emailView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, SCREEN_WIDTH*0.5+30, SCREEN_WIDTH-60, VIEW_HEIGHT) type:ADLTextFieldTypeEmail];
    [self.view addSubview:emailView];
    self.emailView = emailView;
    emailView.hidden = YES;
    
    ADLTextFieldView *pwdView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, SCREEN_WIDTH*0.5+VIEW_HEIGHT+42, SCREEN_WIDTH-60, VIEW_HEIGHT) type:ADLTextFieldTypePwd];
    [self.view addSubview:pwdView];
    self.pwdView = pwdView;
    
    ADLTextFieldView *codeView = [[ADLTextFieldView alloc] initWithFrame:CGRectMake(30, SCREEN_WIDTH*0.5+VIEW_HEIGHT+42, SCREEN_WIDTH-60, VIEW_HEIGHT) type:ADLTextFieldTypeCode];
    [self.view addSubview:codeView];
    self.codeView = codeView;
    codeView.hidden = YES;
    
    __weak typeof(self)weakSelf = self;
    phoneView.willShowView = ^{
        [weakSelf.view endEditing:YES];
    };
    
    emailView.willShowView = ^{
        [weakSelf.view endEditing:YES];
    };
    
    codeView.clickGetCode = ^{
        [weakSelf getMessageCode];
    };
    
    CGFloat msgW = [ADLUtils calculateString:ADLString(@"login_msg") rectSize:CGSizeMake(MAXFLOAT, 40) fontSize:13].width+8;
    UIButton *phoneBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, SCREEN_WIDTH*0.5+VIEW_HEIGHT*2+70, msgW, 40)];
    phoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [phoneBtn setTitle:ADLString(@"login_msg") forState:UIControlStateNormal];
    [phoneBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    phoneBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    phoneBtn.tag = 1;
    [phoneBtn addTarget:self action:@selector(clickPhoneLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phoneBtn];
    self.phoneBtn = phoneBtn;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(msgW+29, SCREEN_WIDTH*0.5+VIEW_HEIGHT*2+84, 0.5, 12)];
    lineView.backgroundColor = COLOR_333333;
    [self.view addSubview:lineView];
    self.lineView = lineView;
    
    CGFloat emailW = [ADLUtils calculateString:ADLString(@"login_email") rectSize:CGSizeMake(MAXFLOAT, 40) fontSize:13].width+8;
    UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    emailBtn.frame = CGRectMake(msgW+30, SCREEN_WIDTH*0.5+VIEW_HEIGHT*2+70, emailW, 40);
    [emailBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    [emailBtn setTitle:ADLString(@"login_email") forState:UIControlStateNormal];
    emailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    emailBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [emailBtn addTarget:self action:@selector(clickEmailLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:emailBtn];
    self.emailBtn = emailBtn;
    self.emailW = emailW;
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    loginBtn.frame = CGRectMake(30, SCREEN_WIDTH*0.5+VIEW_HEIGHT*2+110, SCREEN_WIDTH-60, VIEW_HEIGHT);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitle:ADLString(@"login") forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    loginBtn.backgroundColor = APP_COLOR;
    loginBtn.layer.cornerRadius = CORNER_RADIUS;
    [loginBtn addTarget:self action:@selector(clickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    CGFloat registerW = [ADLUtils calculateString:ADLString(@"register") rectSize:CGSizeMake(MAXFLOAT, 40) fontSize:13].width+10;
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    registerBtn.frame = CGRectMake(30, SCREEN_WIDTH*0.5+VIEW_HEIGHT*3+110, registerW, 40);
    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [registerBtn setTitle:ADLString(@"register") forState:UIControlStateNormal];
    [registerBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [registerBtn addTarget:self action:@selector(clickRegisterBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    CGFloat forgetW = [ADLUtils calculateString:ADLString(@"login_forget") rectSize:CGSizeMake(MAXFLOAT, 40) fontSize:13].width+10;
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    forgetBtn.frame = CGRectMake(SCREEN_WIDTH-forgetW-30, SCREEN_WIDTH*0.5+VIEW_HEIGHT*3+110, forgetW, 40);
    forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [forgetBtn setTitle:ADLString(@"login_forget") forState:UIControlStateNormal];
    [forgetBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [forgetBtn addTarget:self action:@selector(clickForgetPwdBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetBtn];
    
    NSString *str = [NSString stringWithFormat:@"——————    %@    ——————",ADLString(@"login_third")];
    if (SCREEN_WIDTH == 320) {
        str = [NSString stringWithFormat:@"———-    %@    -———",ADLString(@"login_third")];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSForegroundColorAttributeName value:COLOR_333333 range:[str rangeOfString:ADLString(@"login_third")]];
    
    UILabel *thirdLab = [[UILabel alloc] initWithFrame:CGRectMake(18, SCREEN_HEIGHT-BOTTOM_H-104, SCREEN_WIDTH-36, 44)];
    thirdLab.font = [UIFont systemFontOfSize:FONT_SIZE];
    thirdLab.textAlignment = NSTextAlignmentCenter;
    thirdLab.textColor = COLOR_EEEEEE;
    [thirdLab setAttributedText:attrStr];
    [self.view addSubview:thirdLab];
    
    UIButton *qqBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-108)/2, SCREEN_HEIGHT-BOTTOM_H-60, 44, 44)];
    [qqBtn setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(clickQQLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qqBtn];
    
    UIButton *wechatBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH+20)/2, SCREEN_HEIGHT-BOTTOM_H-60, 44, 44)];
    [wechatBtn setImage:[UIImage imageNamed:@"login_wechat"] forState:UIControlStateNormal];
    [wechatBtn addTarget:self action:@selector(clickWeChatLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wechatBtn];
    
    BOOL QQHide = NO;
    BOOL WechatHide = NO;
    if (![QQApiInterface isQQInstalled] && ![QQApiInterface isTIMInstalled]) {
        qqBtn.hidden = YES;
        QQHide = YES;
    }
    if (![WXApi isWXAppInstalled]) {
        wechatBtn.hidden = YES;
        WechatHide = YES;
    }
    if (QQHide && WechatHide) {
        thirdLab.hidden = YES;
    }
    if (!QQHide && WechatHide) {
        qqBtn.frame = CGRectMake((SCREEN_WIDTH-44)/2, SCREEN_HEIGHT-BOTTOM_H-100, 44, 44);
    }
    if (QQHide && !WechatHide) {
        wechatBtn.frame = CGRectMake((SCREEN_WIDTH-44)/2, SCREEN_HEIGHT-BOTTOM_H-100, 44, 44);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWechatData:) name:@"wechatLogin" object:nil];
}

#pragma mark ------ 返回 ------
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------ 密码/短信登录 ------
- (void)clickPhoneLoginBtn {
    if ([self.emailView inputing]) {
        [self.emailView endInputing];
    }
    
    CGFloat Y = self.phoneBtn.frame.origin.y;
    if (self.phoneBtn.tag == 1) {
        self.phoneBtn.tag = 2;
        if ([self.pwdView inputing]) {
            [self.pwdView endInputing];
        }
        
        if (self.emailView.hidden) {
            self.codeView.hidden = NO;
            self.codeView.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.codeView.alpha = 1;
                self.pwdView.alpha = 0;
            } completion:^(BOOL finished) {
                self.pwdView.hidden = YES;
            }];
        } else {
            self.phoneView.hidden = NO;
            self.codeView.hidden = NO;
            self.phoneView.alpha = 0;
            self.codeView.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.pwdView.alpha = 0;
                self.codeView.alpha = 1;
                self.phoneView.alpha = 1;
                self.emailView.alpha = 0;
            } completion:^(BOOL finished) {
                self.pwdView.hidden = YES;
                self.emailView.hidden = YES;
            }];
        }
        
        CGFloat pwdW = [ADLUtils calculateString:ADLString(@"login_pwd") rectSize:CGSizeMake(MAXFLOAT, 40) fontSize:13].width+8;
        [self.phoneBtn setTitle:ADLString(@"login_pwd") forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            self.emailBtn.frame = CGRectMake(pwdW+30, Y, self.emailW, 40);
            self.lineView.frame = CGRectMake(pwdW+29, Y+14, 0.5, 12);
            self.phoneBtn.frame = CGRectMake(30, Y, pwdW, 40);
        }];
    } else {
        self.phoneBtn.tag = 1;
        if ([self.codeView inputing]) {
            [self.codeView endInputing];
        }
        
        if (self.emailView.hidden) {
            self.pwdView.hidden = NO;
            self.pwdView.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.pwdView.alpha = 1;
                self.codeView.alpha = 0;
            } completion:^(BOOL finished) {
                self.codeView.hidden = YES;
            }];
        } else {
            self.phoneView.hidden = NO;
            self.phoneView.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.phoneView.alpha = 1;
                self.emailView.alpha = 0;
            } completion:^(BOOL finished) {
                self.emailView.hidden = YES;
            }];
        }
        
        CGFloat msgW = [ADLUtils calculateString:ADLString(@"login_msg") rectSize:CGSizeMake(MAXFLOAT, 40) fontSize:13].width+8;
        [self.phoneBtn setTitle:ADLString(@"login_msg") forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            self.emailBtn.frame = CGRectMake(msgW+30, Y, self.emailW, 40);
            self.lineView.frame = CGRectMake(msgW+29, Y+14, 0.5, 12);
            self.phoneBtn.frame = CGRectMake(30, Y, msgW, 40);
        }];
    }
}

#pragma mark ------ 邮箱登录 ------
- (void)clickEmailLoginBtn {
    if ([self.phoneView inputing] || [self.codeView inputing]) {
        [self.view endEditing:YES];
    }
    if (self.emailView.hidden) {
        if (self.pwdView.hidden) {
            self.emailView.hidden = NO;
            self.pwdView.hidden = NO;
            self.emailView.alpha = 0;
            self.pwdView.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.emailView.alpha = 1;
                self.pwdView.alpha = 1;
                self.phoneView.alpha = 0;
                self.codeView.alpha = 0;
            } completion:^(BOOL finished) {
                self.phoneView.hidden = YES;
                self.codeView.hidden = YES;
            }];
        } else {
            self.emailView.hidden = NO;
            self.emailView.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.phoneView.alpha = 0;
                self.emailView.alpha = 1;
            } completion:^(BOOL finished) {
                self.phoneView.hidden = YES;
            }];
        }
    }
}

#pragma mark ------ 获取验证码 ------
- (void)getMessageCode {
    if (self.phoneView.text.length == 0) {
        [ADLToast showMessage:ADLString(@"ph_phone")];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:@(3) forKey:@"type"];
        [params setValue:self.phoneView.text forKey:@"phone"];
        [params setValue:self.phoneView.nationCode forKey:@"nationCode"];
        [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
        [ADLToast showLoadingMessage:ADLString(@"loading")];
        [ADLNetWorkManager postWithPath:ADEL_getCode parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
            if ([responseDict[@"code"] integerValue] == 10000) {
                [ADLToast showMessage:ADLString(@"code_success")];
                [self.codeView beginInputing];
                [self.codeView startUpdateTimer];
            }
        } failure:nil];
    }
}

#pragma mark ------ 注册 ------
- (void)clickRegisterBtn {
    ADLRegisterController *registerVC = [[ADLRegisterController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark ------ 忘记密码 ------
- (void)clickForgetPwdBtn {
    ADLModifyPwdController *modifyVC = [[ADLModifyPwdController alloc] init];
    modifyVC.modify = NO;
    [self.navigationController pushViewController:modifyVC animated:YES];
}

#pragma mark ------ 登录 ------
- (void)clickLoginBtn {
    //1 帐号+密码 2 手机+密码 3 邮箱+密码 4 手机+验证码
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (self.phoneView.hidden) {
        if (self.emailView.text.length == 0) {
            [ADLToast showMessage:ADLString(@"ph_email")];
            return;
        }
        if (self.pwdView.text.length < 6) {
            [ADLToast showMessage:ADLString(@"ph_pwd")];
            return;
        }
        
        [params setValue:self.emailView.text forKey:@"loginAccount"];
        [params setValue:[ADLUtils md5Encrypt:self.pwdView.text lower:YES] forKey:@"password"];
        if ([ADLUtils verifyEmailAddress:self.emailView.text]) {
            [params setValue:@(3) forKey:@"type"];
        } else {
            [params setValue:@(1) forKey:@"type"];
        }
    } else {
        if (self.phoneView.text.length == 0) {
            [ADLToast showMessage:ADLString(@"ph_phone")];
            return;
        }
        [params setValue:self.phoneView.text forKey:@"loginAccount"];
        [params setValue:self.phoneView.nationCode forKey:@"nationCode"];
        [params setValue:self.phoneView.nationName forKey:@"nationName"];
        
        if (self.codeView.hidden) {
            if (self.pwdView.text.length < 6) {
                [ADLToast showMessage:ADLString(@"ph_pwd")];
                return;
            }
            [params setValue:[ADLUtils md5Encrypt:self.pwdView.text lower:YES] forKey:@"password"];
            [params setValue:@(2) forKey:@"type"];
        } else {
            if (self.codeView.text.length == 0) {
                [ADLToast showMessage:ADLString(@"ph_code")];
                return;
            }
            [params setValue:self.codeView.text forKey:@"password"];
            [params setValue:@(4) forKey:@"type"];
        }
    }
    
    [params setValue:[ADLUtils valueForKey:DEVICE_TOKEN] forKey:@"imei"];
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    
    [self.view endEditing:YES];
    [ADLToast showLoadingMessage:ADLString(@"logging")];
    [ADLNetWorkManager postWithPath:ADEL_registerLogin parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            if (self.phoneView.hidden) {
                [self saveAccount:NO];
            } else {
                [self saveAccount:YES];
            }
            [self verifyToken:responseDict[@"data"]];
        }
    } failure:nil];
}

#pragma mark ------ QQ登录 ------
- (void)clickQQLoginBtn {
    NSArray *permissions = [NSArray arrayWithObjects:@"get_user_info", nil];
    self.tcOAuth = [[TencentOAuth alloc] initWithAppId:QQ_APPID andDelegate:self];
    [self.tcOAuth authorize:permissions];
}

#pragma mark ------ QQ登录成功,获取Unionid ------
- (void)tencentDidLogin {
    [ADLToast showLoadingMessage:ADLString(@"logging")];
    NSString *path = [NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@&unionid=1",self.tcOAuth.accessToken];
    [self.manager GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *qqCallback = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([qqCallback containsString:@"{"] && [qqCallback containsString:@"}"]) {
            NSRange startR = [qqCallback rangeOfString:@"{\""];
            NSRange endR = [qqCallback rangeOfString:@"\"}"];
            NSRange range = NSMakeRange(startR.location, endR.location-startR.location+2);
            NSString *jsonStr = [qqCallback substringWithRange:range];
            NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if ([dict[@"unionid"] stringValue].length > 2) {
                [self submitThirdLoginWithType:1 unionid:dict[@"unionid"]];
            } else {
                [ADLToast showMessage:ADLString(@"login_failed")];
            }
        } else {
            [ADLToast showMessage:ADLString(@"login_failed")];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ADLToast showMessage:ADLString(@"login_failed")];
    }];
}

#pragma mark ------ QQ登录失败 ------
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        [ADLToast showMessage:ADLString(@"login_cancle")];
    } else {
        [ADLToast showMessage:ADLString(@"login_failed")];
    }
}

#pragma mark ------ QQ登录时网络有问题 ------
- (void)tencentDidNotNetWork {
    [ADLToast showMessage:ADLString(@"login_failed")];
}

#pragma mark ------ 微信登录 ------
- (void)clickWeChatLoginBtn {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    [WXApi sendReq:req completion:nil];
}

#pragma mark ------ 微信登录成功，获取微信Token通知 ------
- (void)getWechatData:(NSNotification *)notification {
    NSString *preStr = @"https://api.weixin.qq.com/sns/oauth2/access_token?grant_type=authorization_code&appid=";
    NSString *path = [NSString stringWithFormat:@"%@%@&secret=%@&code=%@",preStr,WEACHAT_APPID,WEACHAT_SECRET,notification.object];
    [self.manager GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if ([dict[@"unionid"] stringValue].length > 2) {
            [self submitThirdLoginWithType:2 unionid:dict[@"unionid"]];
        } else {
            [ADLToast showMessage:ADLString(@"login_failed")];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ADLToast showMessage:ADLString(@"login_failed")];
    }];
}

#pragma mark ------ 提交第三方登录请求 ------
- (void)submitThirdLoginWithType:(NSInteger)type unionid:(NSString *)unionid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@(type) forKey:@"thirdPartyType"];
    [params setValue:unionid forKey:@"thirdPartyKey"];
    [params setValue:[ADLUtils valueForKey:DEVICE_TOKEN] forKey:@"imei"];
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    [ADLNetWorkManager postWithPath:ADEL_thirdPartyLogin parameters:params autoToast:NO success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            [self verifyToken:responseDict[@"data"]];
        } else if ([responseDict[@"code"] integerValue] == 10022) {
            [ADLToast hide];
            ADLBindOptionController *optionVC = [[ADLBindOptionController alloc] init];
            optionVC.type = type;
            optionVC.unionId = unionid;
            optionVC.finishLogin = ^{
                if (self.loginSuccess) {
                    self.loginSuccess();
                }
            };
            [self.navigationController pushViewController:optionVC animated:YES];
        } else {
            [ADLToast showMessage:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        [ADLToast showMessage:ADLString(@"login_failed")];
    }];
}

#pragma mark ------ 验证Token ------
- (void)verifyToken:(NSMutableDictionary *)dict {
    [ADLNetWorkManager sharedManager].token = dict[@"token"];
    [ADLNetWorkManager postWithPath:k_verify_token parameters:nil autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            [self loginIMWithDict:dict];
        }
    } failure:nil];
}

#pragma mark ------ 登录聊天 ------
- (void)loginIMWithDict:(NSMutableDictionary *)dict {
    [ADLNetWorkManager postWithPath:k_user_im_info parameters:nil autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            [JMSGUser loginWithUsername:responseDict[@"data"][@"userName"] password:responseDict[@"data"][@"password"] completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    [ADLToast showMessage:@"登录失败"];
                } else {
                    [ADLToast hide];
                    [dict setValue:responseDict[@"data"][@"userName"] forKey:@"userName"];
                    [dict setValue:responseDict[@"data"][@"password"] forKey:@"password"];
                    
                    ADLUserModel *model = [ADLUserModel sharedModel];
                    [model setValueWithDict:dict];
                    model.login = YES;
                    [ADLUserModel saveUserModel:model];
                    [ADLRMQConnection sharedConnect].login = YES;
                    [[ADLRMQConnection sharedConnect] startConnection];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFICATION object:nil userInfo:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                    if (self.loginSuccess) {
                        self.loginSuccess();
                    }
                }
            }];
        }
    } failure:nil];
    
    //内网不登录聊天
    //    [ADLToast hide];
    //    ADLUserModel *model = [ADLUserModel sharedModel];
    //    [model setValueWithDict:dict];
    //    model.login = YES;
    //    [ADLUserModel saveUserModel:model];
    //    [ADLRMQConnection sharedConnect].login = YES;
    //    [[ADLRMQConnection sharedConnect] startConnection];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFICATION object:nil userInfo:nil];
    //    [self.navigationController popViewControllerAnimated:YES];
    //    if (self.loginSuccess) {
    //        self.loginSuccess();
    //    }
}

#pragma mark ------ 保存账号记录 ------
- (void)saveAccount:(BOOL)phone {
    if (phone) {
        NSString *phonePath = [ADLUtils filePathWithName:HISTORY_PHONE permanent:YES];
        NSArray *phoneArr = [NSArray arrayWithContentsOfFile:phonePath];
        if (phoneArr == nil) {
            phoneArr = [NSArray arrayWithObject:self.phoneView.text];
            [ADLUtils saveObject:phoneArr fileName:HISTORY_PHONE permanent:YES];
        } else {
            if (![phoneArr containsObject:self.phoneView.text]) {
                NSMutableArray *pArr = [[NSMutableArray alloc] initWithArray:phoneArr];
                [pArr addObject:self.phoneView.text];
                [ADLUtils saveObject:pArr fileName:HISTORY_PHONE permanent:YES];
            }
        }
    } else {
        NSString *emailPath = [ADLUtils filePathWithName:HISTORY_EMAIL permanent:YES];
        NSArray *emailArr = [NSArray arrayWithContentsOfFile:emailPath];
        if (emailArr == nil) {
            emailArr = [NSArray arrayWithObject:self.emailView.text];
            [ADLUtils saveObject:emailArr fileName:HISTORY_EMAIL permanent:YES];
        } else {
            if (![emailArr containsObject:self.emailView.text]) {
                NSMutableArray *eArr = [[NSMutableArray alloc] initWithArray:emailArr];
                [eArr addObject:self.emailView.text];
                [ADLUtils saveObject:eArr fileName:HISTORY_EMAIL permanent:YES];
            }
        }
    }
}

#pragma mark ------ 隐藏键盘 ------
- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark ------ 懒加载 ------
- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [[AFHTTPSessionManager alloc] init];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

@end
