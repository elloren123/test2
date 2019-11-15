//
//  ADLRMQConnection.m
//  lockboss
//
//  Created by Adel on 2019/9/3.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLRMQConnection.h"
#import "ADLLocalizedHelper.h"
#import "ADLNetWorkManager.h"
#import "ADLGlobalDefine.h"
#import "ADLUserModel.h"
#import "ADLAlertView.h"
#import "ADELUrlpath.h"
#import "ADLUtils.h"

#import <RMQClient/RMQChannel.h>
#import <RMQClient/RMQConnection.h>

@interface ADLRMQConnection ()
@property (nonatomic, strong) RMQConnection *connection;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ADLRMQConnection

+ (instancetype)sharedConnect {
    static ADLRMQConnection *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ADLRMQConnection alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startConnection) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeConnection) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeConnection) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

#pragma mark ------ 开始连接 ------
- (void)startConnection {
    if (self.connection != nil) {
        [self.connection close];
        self.connection = nil;
    }
    
    if (self.login) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(resetLoginValue) userInfo:nil repeats:NO];
    }
    
    NSString *queueName = [NSString stringWithFormat:@"%@%@",[ADLUserModel sharedModel].userId, [ADLUtils valueForKey:DEVICE_TOKEN]];
    self.connection = [[RMQConnection alloc] initWithUri:[[ADLNetWorkManager sharedManager] getMqUri] delegate:nil];
    [self.connection start];
    id<RMQChannel> channel = [self.connection createChannel];
    RMQQueue *queue = [channel queue:queueName options:RMQQueueDeclareDurable];
    [queue subscribe:^(RMQMessage * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *msgArr = [[[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"|"];
            NSString *type = msgArr.firstObject;
            NSData *data = [msgArr.lastObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            ADLLog(@"-----------\n\n\n\n  %@ \n\n\n\n------------",info);
            if ([type isEqualToString:@"D1"]) {//开锁
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELOpenLockreceiveMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D2"]) {//对时
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELOpenLockTitleMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D4"]) {//密码管理
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELLockPasswordMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D5"]) {//片管理,删除卡,删除指纹
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamilLocdDeleteCardNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D13"]) {//发卡
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamilLocCardNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D6"]) {//指纹管理
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamilFingerprintNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D7"]) {//恢复出厂设置
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamilRestoreSettingsNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D12"]) {//家庭版常开/常闭
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELLockHomeMedallionNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D13"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamilLocCardNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D15"]) {//升级成功失败返回
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamillockUpgradeStateNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D3"] || [type isEqualToString:@"D20"]) {//酒店单个开门式设置
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELLocksecretManageMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D23"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELfamillockUpgradeNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D27"]) {//组合开门方式设置
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELLoccombinationMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D28"]) {//修改秘钥时间管理
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELModifyPasswordTimeNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"U1"]) {//账号在别的设备登录
                BOOL login = self.login;
                [ADLAlertView showWithTitle:ADLString(@"tips") message:[info[@"msg"] stringValue] confirmTitle:nil confirmAction:^{
                    if (login == NO) {
                        [[ADLNetWorkManager sharedManager] removeUserInfo];
                        UIViewController *controller = [ADLUtils getCurrentViewController];
                        if (controller.navigationController) {
                            [controller.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }
                } cancleTitle:nil cancleAction:nil showCancle:NO];
            } else if ([type isEqualToString:@"D47"]) {//储物箱打开
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELOpenLockStorageBoxMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D46"]) {//燃气阀打开
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELOpenLockGasValveMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D52"]) {//燃气阀或储物箱,设备添加成功
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELAddGasValveStorageBoxMQNotification" object:nil userInfo:info];
            } else if ([type isEqualToString:@"D45"]) {//燃气阀或储物箱,设备添加-->zib打开
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADELAddGasValveStorageBoxZibOpenMQNotification" object:nil userInfo:info];
            } else {
                
            }
        });
    }];
}

- (void)closeConnection {
    if (self.connection != nil) {
        [self.connection close];
        self.connection = nil;
    }
}

- (void)resetLoginValue {
    self.login = NO;
}

@end
