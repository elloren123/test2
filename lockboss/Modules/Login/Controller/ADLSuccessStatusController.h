//
//  ADLSuccessStatusController.h
//  lockboss
//
//  Created by Adel on 2019/11/14.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLBaseViewController.h"

typedef NS_ENUM(NSInteger, ADLSuccessType) {
    ADLSuccessTypeForgetPassword,
    ADLSuccessTypeModifyPassword,
    ADLSuccessTypeRegisterEmail,
    ADLSuccessTypeRegisterPhone,
    ADLSuccessTypeModifyPhone
};

@interface ADLSuccessStatusController : ADLBaseViewController

@property (nonatomic, assign) ADLSuccessType type;

@end
