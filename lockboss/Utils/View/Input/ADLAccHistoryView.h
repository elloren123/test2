//
//  ADLAccHistoryView.h
//  lockboss
//
//  Created by Adel on 2019/9/3.
//  Copyright © 2019 adel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADLAccHistoryView : UIView

/**
 选择历史记录
 
 @param frame 历史记录视图的frame
 @param phone 是否是手机历史记录
 @param change 历史记录数量改变的回调
 @param finish 完成的回调
 @return 历史记录视图
 */
+ (instancetype)showWithFrame:(CGRect)frame phone:(BOOL)phone change:(void(^)(NSInteger num))change finish:(void(^)(NSString *account))finish;

@end
