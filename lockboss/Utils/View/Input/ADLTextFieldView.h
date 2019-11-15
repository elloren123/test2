//
//  ADLTextFieldView.h
//  lockboss
//
//  Created by Adel on 2019/11/13.
//  Copyright © 2019 adel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ADLTextFieldType) {
    ADLTextFieldTypePhone,
    ADLTextFieldTypeEmail,
    ADLTextFieldTypeCode,
    ADLTextFieldTypePwd
};

@interface ADLTextFieldView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(ADLTextFieldType)type;

///点击区号或历史记录
@property (nonatomic, copy) void (^willShowView) (void);

///点击获取验证码
@property (nonatomic, copy) void (^clickGetCode) (void);

///Placeholder,非默认提示赋值用
@property (nonatomic, strong) NSString *placeholder;

///国家名称
@property (nonatomic, strong) NSString *nationName;

///国家区号
@property (nonatomic, strong) NSString *nationCode;

///输入框内容
@property (nonatomic, strong) NSString *text;

///是否显示历史记录
@property (nonatomic, assign) BOOL history;

///开始更新验证码倒计时
- (void)startUpdateTimer;

///开始输入
- (void)beginInputing;

///结束输入
- (void)endInputing;

///是否正在输入
- (BOOL)inputing;

@end
