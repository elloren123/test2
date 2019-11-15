//
//  ADLDiscoveryController.m
//  lockboss
//
//  Created by adel on 2019/3/25.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLDiscoveryController.h"
#import "ADLMessageController.h"
#import "ADLWebViewController.h"
#import "ADLLeagueController.h"
#import "ADLRecordController.h"
#import "ADLSettleController.h"
#import "ADLDatumController.h"

#import "ADLHTMLCommentController.h"
#import "ADLSearchGoodsController.h"
#import "ADLGoodsDetailController.h"

#import "ADLHomeSearchView.h"
#import "ADLStoreHeaderView.h"
#import "ADLDiscoveryCell.h"

@interface ADLDiscoveryController ()<ADLHomeSearchViewDelegate,ADLStoreHeaderViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) ADLHomeSearchView *searchView;
@property (nonatomic, strong) ADLStoreHeaderView *headView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ADLDiscoveryController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    ///导航栏
    ADLHomeSearchView *searchView = [ADLHomeSearchView searchViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAVIGATION_H) delegate:self];
    [self.view addSubview:searchView];
    self.searchView = searchView;
    
    //添加头部视图
    [self addHeadView];
    
    //TableView
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    CGFloat rowH = SCREEN_WIDTH/2+105;
    if (SCREEN_WIDTH > 500) {
        rowH = SCREEN_WIDTH/2+88;
    }
    tableView.rowHeight = rowH;
    tableView.tableHeaderView = self.headView;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    __weak typeof(self)weakSelf = self;
    tableView.mj_header = [ADLRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.offset = 0;
        [weakSelf queryBannerData];
        [weakSelf queryPaperData];
    }];
    
    tableView.mj_footer = [ADLRefreshFooter footerWithRefreshingBlock:^{
        [weakSelf queryPaperData];
    }];
    tableView.mj_footer.hidden = YES;
    
    [self queryBannerData];
    [self queryPaperData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headView beginTimer];
    if (self.searchView.pointView.hidden != [ADLUserModel sharedModel].read) {
        self.searchView.pointView.hidden = [ADLUserModel sharedModel].read;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.headView stopTimer];
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

#pragma mark ------ UITableViewDelegate && DataSource ------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADLDiscoveryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"discovery"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ADLDiscoveryCell" owner:nil options:nil].lastObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (SCREEN_WIDTH > 500)  cell.descLab.numberOfLines = 1;
    }
    NSDictionary *dict = self.dataArr[indexPath.row];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:dict[@"majorImg"]] placeholderImage:[UIImage imageNamed:@"img_rectangle"]];
    cell.titleLab.text = dict[@"title"];
    cell.descLab.text = dict[@"subTitle"];
    cell.dateLab.text = dict[@"addDatetime"];
    cell.seeLab.text = [NSString stringWithFormat:@"%@ 阅读",dict[@"readNum"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ADLHTMLCommentController *htmlVC = [[ADLHTMLCommentController alloc] init];
    htmlVC.hidesBottomBarWhenPushed = YES;
    htmlVC.contentId = self.dataArr[indexPath.row][@"id"];
    [self.navigationController pushViewController:htmlVC animated:YES];
}

#pragma mark ------ 添加头部视图 ------
- (void)addHeadView {
    ADLStoreHeaderView *headView = [ADLStoreHeaderView headViewWithImageArr:@[@"discovery_zsjm",@"discovery_baq",@"discovery_zlk",@"discovery_sjrz"] titleArr:@[@"招商加盟",@"备案区",@"资料库",@"商家入驻"] title:@"商城早报"];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2+VIEW_HEIGHT*2+60);
    headView.delegate = self;
    self.headView = headView;
    
    //判断本地是否缓存有轮播数据
    NSArray *bannerArr = [NSArray arrayWithContentsOfFile:[ADLUtils filePathWithName:DISCOVERY_BANNER permanent:NO]];
    if (bannerArr.count > 0) [headView updateBanner:bannerArr];
    
    //判断本地是否缓存有早报数据
    NSArray *mornArr = [NSArray arrayWithContentsOfFile:[ADLUtils filePathWithName:DISCOVERY_MORNING permanent:NO]];
    if (mornArr.count > 0) [self.dataArr addObjectsFromArray:mornArr];
}

#pragma mark ------ 查询轮播图数据 ------
- (void)queryBannerData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@(4) forKey:@"type"];
    [ADLNetWorkManager postWithPath:k_query_banner parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] integerValue] == 10000) {
            NSArray *resArr = responseDict[@"data"];
            if (resArr.count == 0) {
                [ADLUtils removeObjectWithFileName:DISCOVERY_BANNER permanent:NO];
                [self.headView updateBanner:nil];
            } else {
                [ADLUtils saveObject:resArr fileName:DISCOVERY_BANNER permanent:NO];
                [self.headView updateBanner:resArr];
            }
        }
    } failure:nil];
}

#pragma mark ------ ADLStoreHeaderViewDelegate ------
- (void)didClickHeadView:(NSInteger)tag {
    if ([ADLUserModel sharedModel].login) {
        switch (tag) {
            case 0: {
                ADLLeagueController *leagueVC = [[ADLLeagueController alloc] init];
                leagueVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:leagueVC animated:YES];
            }
                break;
            case 1: {
                ADLRecordController *recordVC = [[ADLRecordController alloc] init];
                recordVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:recordVC animated:YES];
            }
                break;
            case 2: {
                ADLDatumController *datumVC = [[ADLDatumController alloc] init];
                datumVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:datumVC animated:YES];
            }
                break;
            case 3: {
                ADLSettleController *settleVC = [[ADLSettleController alloc] init];
                settleVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:settleVC animated:YES];
            }
                break;
        }
    } else {
        [self pushLoginControllerFinish:nil];
    }
}

#pragma mark ------ 点击Banner ------
- (void)didClickBannerView:(NSString *)urlStr {
    if (urlStr.length > 0) {
        if ([ADLUtils isPureInt:urlStr]) {
            ADLGoodsDetailController *detailVC = [[ADLGoodsDetailController alloc] init];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.goodsId = urlStr;
            [self.navigationController pushViewController:detailVC animated:YES];
        } else {
            if ([urlStr hasPrefix:@"http"]) {
                ADLWebViewController *webVC = [[ADLWebViewController alloc] init];
                webVC.hidesBottomBarWhenPushed = YES;
                webVC.urlString = urlStr;
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
    }
}

#pragma mark ------ 加载早报数据 ------
- (void)queryPaperData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@(self.offset) forKey:@"offset"];
    [params setValue:@(self.pageSize) forKey:@"pageSize"];
    [ADLNetWorkManager postWithPath:k_discovery_list parameters:params autoToast:YES success:^(NSDictionary *responseDict) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if ([responseDict[@"code"] integerValue] == 10000) {
            NSArray *resArr = responseDict[@"data"][@"rows"];
            if (self.offset == 0) {
                [self.dataArr removeAllObjects];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    if (resArr.count == 0) {
                        [ADLUtils removeObjectWithFileName:DISCOVERY_MORNING permanent:NO];
                    } else {
                        [ADLUtils saveObject:resArr fileName:DISCOVERY_MORNING permanent:NO];
                    }
                });
            }
            if (resArr.count > 0) {
                [self.dataArr addObjectsFromArray:resArr];
            }
            if (resArr.count < self.pageSize) {
                self.tableView.mj_footer.hidden = YES;
            } else {
                self.tableView.mj_footer.hidden = NO;
            }
            self.offset = self.dataArr.count;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
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

@end
