//
//  ADLFamilyOpenLockController.m
//  lockboss
//
//  Created by adel on 2019/10/10.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLFamilyOpenLockController.h"

#import "ADLDeviceModel.h"
#import "ADLOpenLockPresent.h"
#import "ADLFamilyOpenLockCell.h"
#import "ADLOpenLockDataSource.h"


#import "ADLLockRecordModel.h"

//#import "ADLBasButton.h"

#import "ADLGlobalDefine.h"

#import "ADLBlankView.h"



@interface ADLFamilyOpenLockController ()<UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) ADLOpenLockPresent *pt;

@property (nonatomic ,strong) ADLOpenLockDataSource *dataSource;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic ,strong) ADLBlankView *blackView;//无数据视图

@end

static NSString *const FamilyOpenLockCell = @"FamilyOpenLockCell";

@implementation ADLFamilyOpenLockController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [self addRedNavigationView:@"开锁记录"];
    
    self.pt = [[ADLOpenLockPresent alloc] init];
    __weak typeof(self) weakSelf = self;
    self.dataSource = [[ADLOpenLockDataSource alloc] initWithIdentifier:FamilyOpenLockCell configureBlock:^(ADLFamilyOpenLockCell * cell, ADLLockRecordModel* model, NSIndexPath * _Nonnull indexPath) {
        //处理cell和model的交互
        [weakSelf connectModelAndCellWith:cell model:model index:indexPath];
    }];
    
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    WS(ws);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws.dataArray  removeAllObjects];
        [ws openLockRecordData];
    } ];

    [self.tableView.mj_header beginRefreshing];
}


#pragma mark ------ 数据源请求 ------
-(void)openLockRecordData {
    [self.pt sendAFWithModel:self.model Success:^(NSDictionary * _Nonnull responseDict, BOOL isGetStorageBox) {
        [self.tableView.mj_header endRefreshing];
        if ([responseDict[@"code"] integerValue] == 10000) {
            @synchronized (self) {
                [self decreaseData];
                if (isGetStorageBox) {
                    NSMutableArray *arr = [ADLLockRecordModel mj_objectArrayWithKeyValuesArray:responseDict[@"data"]];
                    [self.dataArray addObjectsFromArray:arr];
                }else{
                    NSMutableArray *arr = [ADLLockRecordModel mj_objectArrayWithKeyValuesArray:responseDict[@"data"][@"records"]];
                    [self.dataArray addObjectsFromArray:arr];
                }
            }
        }
        if (self.dataArray.count == 0) {
            self.tableView.tableFooterView = self.blackView;
        }else {
            self.tableView.tableFooterView = [UIView new];
        }
        [self.dataSource addDataArray:self.dataArray];
        [self.tableView reloadData];
    } Fial:^{
        [self.tableView.mj_header endRefreshing];
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        self.tableView.tableFooterView = self.blackView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([ADLToast isShowLoading]) {
                [ADLToast hide];
            }
        });
    }];
}

#pragma mark ------ 推送的数量设置 ------
//推送消息数量设置为空
-(void)decreaseData{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"num"] = @(-1);
    [params setValue:[ADLUtils handleParamsSign:params] forKey:@"sign"];
    [ADLNetWorkManager postWithPath:ADEL_decrease parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        ADLLog(@"推送的数量设置 -------%@",responseDict);
        if ([responseDict[@"code"] integerValue] == 10000) {
            [UIApplication  sharedApplication].applicationIconBadgeNumber = 0;
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark ------ tableview Delegate ------
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105;
}

#pragma mark ------ 懒加载 ------
-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray  = [NSMutableArray array];
    }
    return  _dataArray;
}
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_H-BOTTOM_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        [_tableView registerClass:[ADLFamilyOpenLockCell class] forCellReuseIdentifier:FamilyOpenLockCell];
    }
    return  _tableView ;
}

#pragma mark ------ 空数据视图 ------
-(ADLBlankView *)blackView {
    if (!_blackView) {
        _blackView = [ADLBlankView blankViewWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_H) imageName:@"data_blank" prompt:@"没有获取到今天的开锁记录!" backgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
        _blackView.actionBtn.hidden = NO;
        [_blackView.actionBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        __weak typeof(self)weakSelf = self;
        _blackView.clickActionBtn = ^{
            [ADLToast showLoadingMessage:ADLString(@"loading")];
            [weakSelf openLockRecordData];
        };
    }
    return _blackView;
}

#pragma mark ------ 处理cell和model的交互 ------
-(void)connectModelAndCellWith:(ADLFamilyOpenLockCell *)cell model:(ADLLockRecordModel *)model index:(NSIndexPath *)indexPath {
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.headShot] placeholderImage:[UIImage imageNamed:@"bg_headimg"]];
    NSInteger count = [ADLTimeOrStamp timeSwitchTimestamp:[self dateTime:model.openDatetime] andFormatter:@"YYYY-MM-dd HH:mm:ss"];
    cell.timeLabel.text = [self distanceTimeWithBeforeTime:(float)count];
    
    //开锁成功/失败，0失败 1成功
    if ([model.result isEqualToString:@"0"]) {
        cell.icon2.hidden = YES;
        cell.icon3.hidden = YES;
        cell.icon4.hidden = YES;
        cell.icon5.hidden = YES;
        cell.lockTyp.text = @"失败";
        cell.lockTyp.textColor = [UIColor colorWithRed:223/255.0 green:42/255.0 blue:45/255.0 alpha:1.0];//Color999999;
        
        if (model.userName.length > 0) {
            cell.nameLabel.text = model.userName;
        }else {
            cell.nameLabel.text = @"未知";
        }
    }else {
        
        cell.lockTyp.text = @"成功";
        cell.lockTyp.textColor = [UIColor colorWithRed:0/255.0 green:207/255.0 blue:83/255.0 alpha:1.0];//Color0aaa00;
        if (model.userName.length > 0) {
            cell.nameLabel.text = model.userName;
        }else {
            cell.nameLabel.text = @"未知";
        }
    }
    
    //指纹验证状态 0 未验证，1验证成功，2验证失败 int  openGroup 0任意 1开启组合
    if ([_model.openGroup isEqualToString:@"0"]) {
        
        cell.icon2.hidden = YES;
        cell.icon3.hidden = YES;
        cell.icon4.hidden = YES;
        
        if ([model.fingerprintValidation isEqualToString:@"1"]) {
            cell.icon5.hidden = NO;
            cell.icon5.image = [UIImage imageNamed:@"secret_finger_s"];
        }
        if ([model.cardValidation isEqualToString:@"1"]) {
            cell.icon5.hidden = NO;
            cell.icon5.image = [UIImage imageNamed:@"secret_card_s"];
        }
        if ([model.passwordValidation isEqualToString:@"1"]) {
            cell.icon5.hidden = NO;
            cell.icon5.image = [UIImage imageNamed:@"secret_pwd_s"];
        }
        if ([model.phoneValidation isEqualToString:@"1"]) {
            cell.icon5.hidden = NO;
            cell.icon5.image = [UIImage imageNamed:@"secret_phone_s"];
        }
        
    }else{
        cell.icon2.hidden = NO;
        cell.icon3.hidden = NO;
        cell.icon4.hidden = NO;
        cell.icon5.hidden = NO;
        if ([model.fingerprintValidation isEqualToString:@"1"]) {
            cell.icon2.image =[UIImage imageNamed:@"secret_finger_s"];
        }else {
            cell.icon2.image = [UIImage imageNamed:@"secret_finger_n"];
        }
        if ([model.cardValidation isEqualToString:@"1"]) {
            cell.icon5.image =[UIImage imageNamed:@"secret_card_s"];
        }else {
            cell.icon5.image =[UIImage imageNamed:@"secret_card_n"];
        }
        if ([model.passwordValidation isEqualToString:@"1"]) {
            cell.icon3.image = [UIImage imageNamed:@"secret_pwd_s"];
        }else {
            cell.icon3.image = [UIImage imageNamed:@"secret_pwd_n"];
        }
        if ([model.phoneValidation isEqualToString:@"1"]) {
            cell.icon4.image = [UIImage imageNamed:@"secret_phone_s"];
        }else {
            cell.icon4.image =[UIImage imageNamed:@"secret_phone_n"];
        }
    }
}

- (NSString *)dateTime:(NSString *)time {
    NSTimeInterval interval = [time doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
}

- (NSString *)distanceTimeWithBeforeTime:(double)beTime {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [date timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm:ss"];
    NSString * timeStr = [df stringFromDate:beDate];
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    if (distanceTime < 60) {//小于一分钟
        distanceStr = @"刚刚";
    }else if (distanceTime < 60*60) {//时间小于一个小时
        distanceStr = [NSString stringWithFormat:@"%ld分钟前",(long)distanceTime/60];
    }else if(distanceTime < 24*60*60 && [nowDay integerValue] == [lastDay integerValue]){//时间小于一天
        distanceStr = [NSString stringWithFormat:@"今天 %@",timeStr];
    }else if(distanceTime< 24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]){
        if ([nowDay integerValue] - [lastDay integerValue] == 1 || ([lastDay integerValue] - [nowDay integerValue] > 10 && [nowDay integerValue] == 1)) {
            distanceStr = [NSString stringWithFormat:@"昨天 %@",timeStr];
        }else{
            [df setDateFormat:@"MM-dd HH:mm:ss"];
            distanceStr = [df stringFromDate:beDate];
        }
    }else if(distanceTime < 24*60*60*365){
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        distanceStr = [df stringFromDate:beDate];
    }else{
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

@end
