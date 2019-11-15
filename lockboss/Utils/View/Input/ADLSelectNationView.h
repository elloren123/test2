//
//  ADLSelectPhoneView.h
//  lockboss
//
//  Created by adel on 2019/7/3.
//  Copyright © 2019年 adel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADLSelectNationView : UIView

+ (instancetype)showWithFinish:(void(^)(NSDictionary *dict))finish;

@end
