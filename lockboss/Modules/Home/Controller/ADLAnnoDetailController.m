//
//  ADLAnnoDetailController.m
//  lockboss
//
//  Created by adel on 2019/4/22.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLAnnoDetailController.h"

@interface ADLAnnoDetailController ()

@end

@implementation ADLAnnoDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavigationView:@"公告详情"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_H)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = COLOR_F2F2F2;
    [self.view addSubview:scrollView];
    
    UIView *whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:whiteView];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    NSString *title = [self.dict[@"title"] stringValue];
    NSString *content = [self.dict[@"content"] stringValue];
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:style}];
    CGFloat titH = [ADLUtils calculateString:title rectSize:CGSizeMake(SCREEN_WIDTH-60, MAXFLOAT) fontSize:FONT_SIZE].height+40;
    CGFloat conH = [ADLUtils calculateAttributeString:attributeStr rectSize:CGSizeMake(SCREEN_WIDTH-24, MAXFLOAT)].height+10;
    
    UILabel *titLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, SCREEN_WIDTH-60, titH)];
    titLab.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    titLab.textAlignment = NSTextAlignmentCenter;
    titLab.textColor = COLOR_333333;
    titLab.numberOfLines = 0;
    titLab.text = title;
    [whiteView addSubview:titLab];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(12, titH-3, SCREEN_WIDTH-24, conH)];
    contentLab.font = [UIFont systemFontOfSize:13];
    contentLab.attributedText = attributeStr;
    contentLab.textColor = COLOR_666666;
    contentLab.numberOfLines = 0;
    [whiteView addSubview:contentLab];
    
    UILabel *bossLab = [[UILabel alloc] initWithFrame:CGRectMake(12, titH+conH+17, SCREEN_WIDTH-24, 20)];
    bossLab.textAlignment = NSTextAlignmentRight;
    bossLab.font = [UIFont systemFontOfSize:13];
    bossLab.textColor = COLOR_999999;
    bossLab.text = @"锁老大";
    [whiteView addSubview:bossLab];
    
    NSString *dateStr = [ADLUtils getDateFromTimestamp:[self.dict[@"addDatetime"] doubleValue] format:@"yyyy-MM-dd"];
    UILabel *dateLab = [[UILabel alloc] initWithFrame:CGRectMake(12, titH+conH+40, SCREEN_WIDTH-24, 20)];
    dateLab.textAlignment = NSTextAlignmentRight;
    dateLab.font = [UIFont systemFontOfSize:13];
    dateLab.textColor = COLOR_999999;
    dateLab.text = dateStr;
    [whiteView addSubview:dateLab];
    
    whiteView.frame = CGRectMake(0, 10, SCREEN_WIDTH, titH+conH+70);
    if (titH+conH+80 < SCREEN_HEIGHT-NAVIGATION_H) {
        scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT-NAVIGATION_H+1);
    } else {
        scrollView.contentSize = CGSizeMake(0, titH+conH+80);
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressContentText:)];
    [contentLab addGestureRecognizer:longPress];
}

#pragma mark ------ 复制 ------
- (void)longPressContentText:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [ADLAlertView showWithTitle:ADLString(@"tips") message:@"复制文本" confirmTitle:@"复制" confirmAction:^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [self.dict[@"content"] stringValue];
            [ADLToast showMessage:@"复制成功"];
        } cancleTitle:nil cancleAction:nil showCancle:YES];
    }
}

@end
