//
//  ADLHomeController.m
//  lockboss
//
//  Created by adel on 2019/3/25.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLHomeController.h"
#import "ADLBookingHotelController.h"
#import "ADLGoodsDetailController.h"
#import "ADLLockServiceController.h"
#import "ADLSearchGoodsController.h"
#import "ADLAnnoDetailController.h"
#import "ADLLockHomeController.h"
#import "ADLMessageController.h"
#import "ADLWebViewController.h"
#import "ADLCircleController.h"

#import "ADLHomeSearchView.h"
#import "ADLHomeCellView.h"
#import "ADLMarqueeView.h"
#import "ADLBannerView.h"

@interface ADLHomeController ()<ADLHomeSearchViewDelegate,ADLHomeCellViewDelegate>
@property (nonatomic, strong) ADLHomeSearchView *searchView;
@property (nonatomic, strong) ADLMarqueeView *marqueeView;
@property (nonatomic, strong) ADLBannerView *bannerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ADLHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_H-self.tabBarController.tabBar.frame.size.height)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    __weak typeof(self)weakSelf = self;
    scrollView.mj_header = [ADLRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf getBannerData];
        [weakSelf getAnnouncementData];
    }];
    
    //初始化视图
    [self addBannerView];
    [self addAnnouncementView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUnreadMessage) name:LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endPlayVideo) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    if ([ADLUserModel sharedModel].login) [self queryUnreadMessage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bannerView startTimer];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (self.searchView.pointView.hidden != [ADLUserModel sharedModel].read) {
        self.searchView.pointView.hidden = [ADLUserModel sharedModel].read;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bannerView.timer invalidate];
}

#pragma mark ------ ADLHomeSearchViewDelegate ------
- (void)didClickHomeSearchView:(NSInteger)index {
    if (index == 0) {
        ADLSearchGoodsController *goodsVC = [[ADLSearchGoodsController alloc] init];
        goodsVC.hidesBottomBarWhenPushed = YES;
        [self customPushViewController:goodsVC];
    } else {
        if ([ADLUserModel sharedModel].login) {
            ADLMessageController *messageVC = [[ADLMessageController alloc] init];
            messageVC.hidesBottomBarWhenPushed = YES;
            messageVC.finishBlock = ^{
                [self queryUnreadMessage];
            };
            [self.navigationController pushViewController:messageVC animated:YES];
        } else {
            [self pushLoginControllerFinish:nil];
        }
    }
}

#pragma mark ------ ADLHomeCellViewDelegate ------
- (void)didClickCellAtIndex:(NSInteger)index {
    if (index == 2) {
        [self.tabBarController setSelectedIndex:1];
    } else {
        if ([ADLUserModel sharedModel].login) {
            switch (index) {
                case 0:{
                    ADLLockHomeController *lockVC = [[ADLLockHomeController alloc] init];
                    lockVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:lockVC animated:YES];
                }
                    break;
                case 1:{
                    ADLBookingHotelController *bookingVC = [[ADLBookingHotelController alloc] init];
                    bookingVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:bookingVC animated:YES];
                }
                    break;
                case 3:{
                    ADLLockServiceController *serviceVC = [[ADLLockServiceController alloc] init];
                    serviceVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:serviceVC animated:YES];
                }
                    break;
                case 4:{
                    ADLCircleController *groupVC = [[ADLCircleController alloc] init];
                    groupVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:groupVC animated:YES];
                }
                    break;
                case 5:{
                    
                }
                    break;
            }
        } else {
            [self pushLoginControllerFinish:nil];
        }
    }
}

#pragma mark ------ 添加搜索、轮播图 ------
- (void)addBannerView {
    ADLHomeSearchView *searchView = [ADLHomeSearchView searchViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAVIGATION_H) delegate:self];
    [self.view addSubview:searchView];
    self.searchView = searchView;
    
    //轮播图
    ADLBannerView *bannerView = [[ADLBannerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2) position:ADLPagePositionCenetr style:ADLPageStyleRound];
    [self.scrollView addSubview:bannerView];
    self.bannerView = bannerView;
    
    __weak typeof(self)weakSelf = self;
    bannerView.clickBanner = ^(NSString *str) {
        if ([ADLUtils isPureInt:str]) {
            ADLGoodsDetailController *detailVC = [[ADLGoodsDetailController alloc] init];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.goodsId = str;
            [weakSelf.navigationController pushViewController:detailVC animated:YES];
        } else {
            if ([str hasPrefix:@"http"]) {
                ADLWebViewController *webVC = [[ADLWebViewController alloc] init];
                webVC.hidesBottomBarWhenPushed = YES;
                webVC.urlString = str;
                [weakSelf.navigationController pushViewController:webVC animated:YES];
            }
        }
    };
    
    //判断本地是否缓存有轮播数据
    NSArray *cacheArr = [NSArray arrayWithContentsOfFile:[ADLUtils filePathWithName:HOME_BANNER permanent:NO]];
    if (cacheArr.count > 0) [bannerView updateBanner:cacheArr imgKey:nil urlKey:nil];
    
    [self getBannerData];
}

#pragma mark ------ 获取轮播图数据 ------
- (void)getBannerData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@(3) forKey:@"type"];
    [ADLNetWorkManager postWithPath:k_query_banner parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        [self.scrollView.mj_header endRefreshing];
        if ([responseDict[@"code"] integerValue] == 10000) {
            NSArray *resArr = responseDict[@"data"];
            if (resArr.count == 0) {
                [ADLUtils removeObjectWithFileName:HOME_BANNER permanent:NO];
            } else {
                [ADLUtils saveObject:resArr fileName:HOME_BANNER permanent:NO];
            }
            [self.bannerView updateBanner:resArr imgKey:nil urlKey:nil];
        }
    } failure:^(NSError *error) {
        [self.scrollView.mj_header endRefreshing];
    }];
}

#pragma mark ------ 添加公告、六宫格 ------
- (void)addAnnouncementView {
    ADLMarqueeView *marqueeView = [[ADLMarqueeView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2, SCREEN_WIDTH, VIEW_HEIGHT) image:[UIImage imageNamed:@"home_notice"] timeInterval:2];
    [self.scrollView addSubview:marqueeView];
    self.marqueeView = marqueeView;
    
    __weak typeof(self)weakSelf = self;
    marqueeView.clickMarqueeView = ^(NSInteger index) {
        ADLAnnoDetailController *detailVC = [[ADLAnnoDetailController alloc] init];
        detailVC.dict = weakSelf.dataArr[index];
        detailVC.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    };
    
    NSArray *annArr = [NSArray arrayWithContentsOfFile:[ADLUtils filePathWithName:HOME_ANNOUNCEMENT permanent:NO]];
    NSMutableArray *muArr = [ADLUtils dictArrayToArray:annArr key:@"title"];
    if (muArr.count > 0) {
        marqueeView.contentArr = muArr;
        [self.dataArr addObjectsFromArray:annArr];
    }
    
    //六宫格
    CGFloat gap = 9;
    if (SCREEN_WIDTH > 500) gap = 18;
    if (SCREEN_WIDTH < 360) gap = 6;
    CGFloat cellW = (SCREEN_WIDTH-gap*4)/3;
    ADLHomeCellView *cellView = [[ADLHomeCellView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH/2+VIEW_HEIGHT, SCREEN_WIDTH, cellW*2+gap*3) gap:gap cellW:cellW];
    cellView.delegate = self;
    [self.scrollView addSubview:cellView];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH/2+VIEW_HEIGHT+cellW*2+gap*3);
    [self getAnnouncementData];
}

#pragma mark ------ 获取公告数据 ------
- (void)getAnnouncementData {
    [ADLNetWorkManager postWithPath:k_query_announcement parameters:nil autoToast:YES success:^(NSDictionary *responseDict) {
        if ([self.scrollView.mj_header isRefreshing]) {
            [self.scrollView.mj_header endRefreshing];
        }
        if ([responseDict[@"code"] integerValue] == 10000) {
            NSArray *resArr = responseDict[@"data"];
            [self.dataArr removeAllObjects];
            if (resArr.count > 0) {
                if (resArr.count == 1) {
                    [self.dataArr addObject:resArr[0]];
                    [self.dataArr addObject:resArr[0]];
                } else {
                    [self.dataArr addObjectsFromArray:resArr];
                }
                [ADLUtils saveObject:self.dataArr fileName:HOME_ANNOUNCEMENT permanent:NO];
                self.marqueeView.contentArr = [ADLUtils dictArrayToArray:self.dataArr key:@"title"];
            } else {
                self.marqueeView.contentArr = nil;
                [ADLUtils removeObjectWithFileName:HOME_ANNOUNCEMENT permanent:NO];
            }
        }
    } failure:^(NSError *error) {
        if ([self.scrollView.mj_header isRefreshing]) {
            [self.scrollView.mj_header endRefreshing];
        }
    }];
}

#pragma mark ------ 查询是否有未读消息 ------
- (void)queryUnreadMessage {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ADLUserModel sharedModel].userId forKey:@"userId"];
    [params setValue:@(0) forKey:@"stype"];
    [ADLNetWorkManager postWithPath:k_query_unread_msg parameters:params autoToast:NO success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            [ADLUserModel sharedModel].read = [responseDict[@"data"][@"isRead"] boolValue];
            if (self.searchView.pointView.hidden != [ADLUserModel sharedModel].read) {
                self.searchView.pointView.hidden = [ADLUserModel sharedModel].read;
            }
        }
    } failure:nil];
}

#pragma mark ------ WebView视频播放结束通知 ------
- (void)endPlayVideo {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
