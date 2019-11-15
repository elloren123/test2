//
//  ADLAddFamilyDeviceController.m
//  lockboss
//
//  Created by Adel on 2019/9/4.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLAddFamilyDeviceController.h"
#import "ADLKeyboardMonitor.h"
#import "HFSmartLink.h"

#import <AFNetworking.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ADLAddFamilyDeviceController ()<AMapLocationManagerDelegate,UITextFieldDelegate>
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) HFSmartLink *smartLink;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextField *remarkTF;
@property (nonatomic, strong) UITextField *nameTF;
@property (nonatomic, strong) UITextField *pwdTF;
@property (nonatomic, strong) UIButton *rememberBtn;
@property (nonatomic, strong) NSString *wifiMac;
@property (nonatomic, assign) BOOL connecting;
@property (nonatomic, assign) BOOL wifi;
@end

@implementation ADLAddFamilyDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wifi = NO;
    self.connecting = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    [self addRedNavigationView:self.titName];
    [self setupSubViews];
    
    if ([ADLUtils getLocationStatus] == ADLLocationStatusAllow) {
        AMapLocationManager *locationManager = [[AMapLocationManager alloc] init];
        locationManager.locatingWithReGeocode = YES;
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        self.locationManager = locationManager;
    }
    
    self.smartLink = [HFSmartLink shareInstence];
    self.smartLink.isConfigOneDevice = YES;
    self.smartLink.waitTimers = 60;
    
    [self monitorNetworkStatus];
    [[ADLKeyboardMonitor monitor] setEnable:YES];
}

#pragma mark ------ 初始化视图 ------
- (void)setupSubViews {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2, 60, 80, 60)];
    imgView.image = [UIImage imageNamed:@"wifi_unconnected"];
    [self.contentView addSubview:imgView];
    self.imgView = imgView;
    
    CGFloat beginY = 200;
    if (self.deviceMac.length == 0) {
        beginY= VIEW_HEIGHT+212;
        UIView *remarkView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, SCREEN_WIDTH-40, VIEW_HEIGHT)];
        remarkView.layer.borderColor = COLOR_D3D3D3.CGColor;
        remarkView.layer.cornerRadius = CORNER_RADIUS;
        remarkView.layer.borderWidth = 0.5;
        [self.contentView addSubview:remarkView];
        
        UITextField *remarkTF = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-57, VIEW_HEIGHT)];
        remarkTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        remarkTF.font = [UIFont systemFontOfSize:FONT_SIZE];
        remarkTF.borderStyle = UITextBorderStyleNone;
        remarkTF.returnKeyType = UIReturnKeyDone;
        remarkTF.placeholder = @"设置备注名";
        remarkTF.textColor = COLOR_333333;
        remarkTF.delegate = self;
        [remarkView addSubview:remarkTF];
        self.remarkTF = remarkTF;
    }
    
    UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(20, beginY, SCREEN_WIDTH-40, VIEW_HEIGHT)];
    nameView.layer.borderColor = COLOR_D3D3D3.CGColor;
    nameView.layer.cornerRadius = CORNER_RADIUS;
    nameView.layer.borderWidth = 0.5;
    [self.contentView addSubview:nameView];
    
    UITextField *nameTF = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-57, VIEW_HEIGHT)];
    nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTF.font = [UIFont systemFontOfSize:FONT_SIZE];
    nameTF.borderStyle = UITextBorderStyleNone;
    nameTF.returnKeyType = UIReturnKeyDone;
    nameTF.placeholder = @"请输入WIFI名称";
    nameTF.textColor = COLOR_333333;
    nameTF.delegate = self;
    [nameView addSubview:nameTF];
    self.nameTF = nameTF;
    
    UIView *pwdView = [[UIView alloc] initWithFrame:CGRectMake(20, beginY+VIEW_HEIGHT+12, SCREEN_WIDTH-40, VIEW_HEIGHT)];
    pwdView.layer.borderColor = COLOR_D3D3D3.CGColor;
    pwdView.layer.cornerRadius = CORNER_RADIUS;
    pwdView.layer.borderWidth = 0.5;
    [self.contentView addSubview:pwdView];
    
    UITextField *pwdTF = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-91, VIEW_HEIGHT)];
    pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    pwdTF.font = [UIFont systemFontOfSize:FONT_SIZE];
    pwdTF.keyboardType = UIKeyboardTypeASCIICapable;
    pwdTF.borderStyle = UITextBorderStyleNone;
    pwdTF.returnKeyType = UIReturnKeyDone;
    pwdTF.placeholder = @"请输入WIFI密码";
    pwdTF.textColor = COLOR_333333;
    pwdTF.secureTextEntry = YES;
    pwdTF.delegate = self;
    if (@available(iOS 10.0, *)) {
        pwdTF.textContentType = UITextContentTypeName;
    }
    [pwdView addSubview:pwdTF];
    self.pwdTF = pwdTF;
    
    UIButton *showBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-79, 0, 39, VIEW_HEIGHT)];
    [showBtn setImage:[UIImage imageNamed:@"login_hide"] forState:UIControlStateNormal];
    [showBtn setImage:[UIImage imageNamed:@"login_show"] forState:UIControlStateSelected];
    showBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    showBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 12);
    showBtn.adjustsImageWhenHighlighted = NO;
    [showBtn addTarget:self action:@selector(clickShowPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
    [pwdView addSubview:showBtn];
    
    CGFloat btnW = [ADLUtils calculateString:ADLString(@"save_wifi") rectSize:CGSizeMake(SCREEN_WIDTH-60, 20) fontSize:13].width+30;
    UIButton *rememberBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, beginY+VIEW_HEIGHT*2+12, btnW, 40)];
    rememberBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [rememberBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    [rememberBtn setTitle:ADLString(@"save_wifi") forState:UIControlStateNormal];
    [rememberBtn setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
    [rememberBtn setImage:[UIImage imageNamed:@"check_selected"] forState:UIControlStateSelected];
    rememberBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    rememberBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [rememberBtn addTarget:self action:@selector(clickRememberBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:rememberBtn];
    self.rememberBtn = rememberBtn;
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmBtn.frame = CGRectMake(20, SCREEN_HEIGHT-NAVIGATION_H-BOTTOM_H-80, SCREEN_WIDTH-40, VIEW_HEIGHT);
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    confirmBtn.backgroundColor = APP_COLOR;
    confirmBtn.layer.cornerRadius = CORNER_RADIUS;
    [confirmBtn addTarget:self action:@selector(clickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:confirmBtn];
}

#pragma mark ------ UITextFieldDelegate ------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    __weak typeof(self)weakSelf = self;
    CGFloat bottomH = [ADLUtils convertRectWithView:textField];
    [ADLKeyboardMonitor monitor].keyboardTransform = ^(CGFloat keyboardH) {
        if (keyboardH == 0) {
            weakSelf.contentView.transform = CGAffineTransformIdentity;
        } else {
            if (bottomH < keyboardH) {
                weakSelf.contentView.transform = CGAffineTransformMakeTranslation(0, -keyboardH+bottomH);
            }
        }
    };
}

#pragma mark ------ 定位成功 ------
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    if (reGeocode.city) {
        [self.locationManager stopUpdatingLocation];
        self.latitude = location.coordinate.latitude;
        self.longitude = location.coordinate.longitude;
    }
}

#pragma mark ------ 获取无线网络信息 ------
- (void)SSIDInformation {
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    NSDictionary *infoDict = nil;
    for (NSString *ifnam in ifs) {
        infoDict = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if ([infoDict count]) {
            break;
        }
    }
    if (infoDict) {
        NSString *wifiNmae = infoDict[@"SSID"];
        self.nameTF.text = wifiNmae;
        NSDictionary *wifiDict = [ADLUtils valueForKey:@"wifi_info"];
        if (wifiDict[wifiNmae]) {
            self.pwdTF.text = wifiDict[wifiNmae];
        }
    }
    self.wifiMac = [infoDict[@"BSSID"] stringByReplacingOccurrencesOfString:@":" withString:@""];
}

#pragma mark ------ 显示隐藏密码 ------
- (void)clickShowPwdBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.pwdTF.secureTextEntry = NO;
    } else {
        self.pwdTF.secureTextEntry = YES;
    }
    [ADLUtils dealWithSecureEntryWithTextField:self.pwdTF];
}

#pragma mark ------ 点击记住密码 ------
- (void)clickRememberBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark ------ 确定 ------
- (void)clickConfirmBtn {
    if (self.wifi == NO) {
        [ADLToast showMessage:@"请连接WIFI"];
        return;
    }
    if (self.nameTF.text.length == 0) {
        [ADLToast showMessage:@"请输入WIFI名称"];
        return;
    }
    if (self.pwdTF.text.length == 0) {
        [ADLToast showMessage:@"请输入WIFI密码"];
        return;
    }
    [ADLToast showLoadingMessage:@"连接中..."];
    if (self.connecting) {
        [self.smartLink stopWithBlock:nil];
    }
    
    self.connecting = YES;
    __weak typeof(self)weakSelf = self;
    [self.smartLink startWithSSID:self.nameTF.text Key:self.pwdTF.text withV3x:YES processblock:^(NSInteger process) {
        
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
        if (weakSelf.deviceMac.length > 0) {
            [weakSelf changeWIFI:dev.ip mac:dev.mac];
        } else {
            [weakSelf dataWIFI:dev.ip mac:dev.mac];
        }
    } failBlock:^(NSString *failmsg) {
        [ADLToast showMessage:failmsg];
    } endBlock:^(NSDictionary *deviceDic) {
        weakSelf.connecting = NO;
    }];
}

- (void)dataWIFI:(NSString *)ip mac:(NSString *)mac {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:mac forKey:@"mac"];
    [params setValue:ip forKey:@"routerIp"];
    [params setValue:self.wifiMac forKey:@"routerMac"];
    [params setValue:self.remarkTF.text forKey:@"name"];
    [params setValue:self.nameTF.text forKey:@"routerName"];
    [params setValue:@(self.longitude) forKey:@"longitude"];
    [params setValue:@(self.latitude) forKey:@"latitude"];
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    [ADLNetWorkManager postWithPath:ADEL_familydev_add parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            if (self.rememberBtn.selected) {
                [self saveWifiInfo];
            }
            [ADLToast showMessage:@"添加成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:nil];
}

- (void)changeWIFI:(NSString *)ip mac:(NSString *)mac {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:ip forKey:@"ip"];
    [params setValue:mac forKey:@"mac"];
    [params setValue:self.nameTF.text forKey:@"name"];
    [params setValue:self.deviceMac forKey:@"deviceMac"];
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    [ADLNetWorkManager postWithPath:ADEL_familydev_Changwifi parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            if (self.rememberBtn.selected) {
                [self saveWifiInfo];
            }
            [ADLToast showMessage:@"更换成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:nil];
}

#pragma mark ------ 保存Wifi信息 ------
- (void)saveWifiInfo {
    NSMutableDictionary *wifiDict;
    NSDictionary *dict = [ADLUtils valueForKey:@"wifi_info"];
    if (dict) {
        wifiDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    } else {
        wifiDict = [[NSMutableDictionary alloc] init];
    }
    [wifiDict setValue:self.pwdTF.text forKey:self.nameTF.text];
    [ADLUtils saveValue:wifiDict forKey:@"wifi_info"];
}

#pragma mark ------ 监听网络状态 ------
- (void)monitorNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                self.wifi = YES;
                self.imgView.image = [UIImage imageNamed:@"wifi_connected"];
                [self SSIDInformation];
            } else {
                self.wifi = NO;
                self.imgView.image = [UIImage imageNamed:@"wifi_unconnected"];
                if (self.connecting) {
                    self.connecting = NO;
                    [ADLToast showMessage:@"添加失败"];
                    [self.smartLink stopWithBlock:nil];
                }
            }
        });
    }];
    [manager startMonitoring];
}

#pragma mark ------ 退出键盘 ------
- (void)hideKeyBoard {
    [self.contentView endEditing:YES];
}

- (void)dealloc {
    [[ADLKeyboardMonitor monitor] setEnable:NO];
}

@end
