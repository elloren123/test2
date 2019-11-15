//
//  ADLUnlockPatternController.h
//  lockboss
//
//  Created by Adel on 2019/9/5.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLBaseViewController.h"

@class ADLDeviceModel;

@interface ADLUnlockPatternController : ADLBaseViewController

@property (nonatomic, strong) ADLDeviceModel *model;

@property (nonatomic, assign) BOOL isHotel;//是否是酒店,家庭不传,酒店传YES


@end
