//
//  ADLOpenLockPresent.m
//  lockboss
//
//  Created by adel on 2019/11/15.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLOpenLockPresent.h"
#import "ADELUrlpath.h"
#import "ADLNetWorkManager.h"

@implementation ADLOpenLockPresent

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark ------ 获取开锁记录 ------
-(void)sendAFWithModel:(ADLDeviceModel *)model Success:(Success)success Fial:(Fail)fail{
    if (!model) {
        fail();
    }else{
        if([model.deviceType isEqualToString:@"51"] ||[model.deviceType isEqualToString:@"41"] ){
            NSString *url = nil;
            if ([model.deviceType isEqualToString:@"51"]) {
                url = ADEL_family_openLockStorageBox;
            }else{
                url = ADEL_family_openLockGasValve;
            }
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"deviceId"] = model.deviceId;
            params[@"deviceCode"] = model.deviceCode;
            params[@"id"] = @"";// 记录id ,这样定义字段真的好吗????
            [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
            [self networkWith:url mes:params isGetStorageBox:NO Success:success Fial:fail];
        }else {
            NSDate *currentDate = [NSDate date];
            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy-MM"];
            NSString *start=[dateformatter stringFromDate:currentDate];
            
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSString *url;
            url = ADEL_family_openLockRecord;
            params[@"deviceId"] = model.deviceId;// 设备id
            params[@"deviceMac"] = model.deviceMac;// 设备id
            params[@"deviceCode"] = model.deviceCode;// 设备id
            params[@"deviceType"] = model.deviceType;// 设备id
            NSArray *array = [start componentsSeparatedByString:@"-"];
            params[@"recordId"] =@"";// 记录id
            params[@"year"] =array[0];
            params[@"month"] =array[1];
            [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
            [self networkWith:url mes:params isGetStorageBox:NO Success:success Fial:fail];
        }
    }
    
}
-(void)networkWith:(NSString *)url mes:(NSDictionary *)params isGetStorageBox:(BOOL)isGetStorageBox Success:(Success)success Fial:(Fail)fail{
    [ADLNetWorkManager postWithPath:url parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        success(responseDict,isGetStorageBox);
    } failure:^(NSError *error) {
        fail();
    }];
}

#pragma mark ------ lazy ------
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray;
}


@end
