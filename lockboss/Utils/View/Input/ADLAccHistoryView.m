//
//  ADLAccHistoryView.m
//  lockboss
//
//  Created by Adel on 2019/9/3.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLAccHistoryView.h"
#import "ADLAccHistoryCell.h"
#import "ADLGlobalDefine.h"
#import "ADLUtils.h"

@interface ADLAccHistoryView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,ADLAccHistoryCellDelegate>
@property (nonatomic, copy) void (^finish) (NSString *account);
@property (nonatomic, copy) void (^change) (NSInteger num);
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, assign) BOOL phone;
@end

@implementation ADLAccHistoryView

+ (instancetype)showWithFrame:(CGRect)frame phone:(BOOL)phone change:(void (^)(NSInteger))change finish:(void (^)(NSString *))finish {
    return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds panleFrame:frame phone:phone change:change finish:finish];
}

- (instancetype)initWithFrame:(CGRect)frame panleFrame:(CGRect)panleFrame phone:(BOOL)phone change:(void (^)(NSInteger))change finish:(void (^)(NSString *))finish {
    if (self = [super initWithFrame:frame]) {
        self.phone = phone;
        self.change = change;
        self.finish = finish;
        
        NSString *filePath = nil;
        if (phone) {
            filePath = [ADLUtils filePathWithName:HISTORY_PHONE permanent:YES];
        } else {
            filePath = [ADLUtils filePathWithName:HISTORY_EMAIL permanent:YES];
        }
        NSArray *localArr = [NSArray arrayWithContentsOfFile:filePath];
        if (localArr.count > 0) {
            self.dataArr = [[NSMutableArray alloc] initWithArray:localArr];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverView)];
            tap.delegate = self;
            [self addGestureRecognizer:tap];
            
            UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(panleFrame.origin.x, SCREEN_HEIGHT, panleFrame.size.width, panleFrame.size.height)];
            panelView.backgroundColor = [UIColor whiteColor];
            panelView.layer.borderColor = COLOR_D3D3D3.CGColor;
            panelView.layer.cornerRadius = CORNER_RADIUS;
            panelView.layer.borderWidth = 0.5;
            panelView.clipsToBounds = YES;
            [self addSubview:panelView];
            self.panelView = panelView;
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, panleFrame.size.width, panleFrame.size.height)];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.rowHeight = 44;
            tableView.delegate = self;
            tableView.dataSource = self;
            [panelView addSubview:tableView];
            self.tableView = tableView;
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:self];
            [UIView animateWithDuration:0.3 animations:^{
                panelView.frame = panleFrame;
            }];
        }
    }
    return self;
}

#pragma mark ------ UITableView Delegate && DataSource ------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADLAccHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history"];
    if (cell == nil) {
        cell = [[ADLAccHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"history"];
        cell.delegate = self;
    }
    cell.accountLab.text = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.finish) {
        self.finish(self.dataArr[indexPath.row]);
    }
    [self removeHistoryView];
}

#pragma mark ------ UIGestureRecognizerDelegate ------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    }
    return  YES;
}

#pragma mark ------ 删除 ------
- (void)didClickDeleteBtn:(UIButton *)sender {
    ADLAccHistoryCell *cell = (ADLAccHistoryCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSString *fileName = self.phone ? HISTORY_PHONE : HISTORY_EMAIL;
    if (self.dataArr.count == 0) {
        [ADLUtils removeObjectWithFileName:fileName permanent:YES];
        [self removeHistoryView];
    } else {
        [ADLUtils saveObject:self.dataArr fileName:fileName permanent:YES];
    }
    if (self.change) {
        self.change(self.dataArr.count);
    }
}

#pragma mark ------ 点击遮罩 ------
- (void)clickCoverView {
    if (self.finish) {
        self.finish(nil);
    }
    [self removeHistoryView];
}

#pragma mark ------ 移除 ------
- (void)removeHistoryView {
    CGRect frame = self.panelView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    [UIView animateWithDuration:0.3 animations:^{
        self.panelView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
