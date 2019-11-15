//
//  ADLMarqueeView.h
//  lockboss
//
//  Created by Adel on 2019/11/13.
//  Copyright © 2019 adel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADLMarqueeView : UIView

///初始化
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image timeInterval:(NSTimeInterval)timeInterval;

///点击事件
@property (nonatomic, copy) void (^clickMarqueeView) (NSInteger index);

///轮播内容数组
@property (nonatomic, strong) NSMutableArray<NSString *> *contentArr;

///左边图片
@property (nonatomic, strong) UIImage *image;

///图片大小
@property (nonatomic, assign) CGSize imgSize;

///背景颜色
@property (nonatomic, strong) UIColor *bgColor;

///文字颜色
@property (nonatomic, strong) UIColor *textColor;

///字体大小
@property (nonatomic, strong) UIFont *textFont;

///定时器
@property (nonatomic, strong) NSTimer *timer;

@end
