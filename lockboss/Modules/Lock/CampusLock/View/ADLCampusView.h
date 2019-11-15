//
//  ADLCampusView.h
//  lockboss
//
//  Created by Adel on 2019/8/27.
//  Copyright © 2019 adel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADLCampusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADLCampusView : UIView

//跳转界面block
@property (nonatomic, copy) void(^pushVCBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
