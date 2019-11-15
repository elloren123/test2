//
//  ADLOpenLockPresent.h
//  lockboss
//
//  Created by adel on 2019/11/15.
//  Copyright © 2019 adel. All rights reserved.
/*
 这里不需要UIKit框架,单纯的做数据的处理
 */

#import <Foundation/Foundation.h>
#import "ADLDeviceModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^Success)(NSDictionary * responseDict,BOOL isGetStorageBox);
typedef void (^Fail)(void);

@interface ADLOpenLockPresent : NSObject

@property (nonatomic, strong) NSMutableArray    *dataArray;

//请求数据
-(void)sendAFWithModel:(ADLDeviceModel *)model Success:(Success)success Fial:(Fail)fail;

@end

NS_ASSUME_NONNULL_END
