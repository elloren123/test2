//
//  ADLSelectPhoneView.m
//  lockboss
//
//  Created by adel on 2019/7/3.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLSelectNationView.h"
#import "ADLSelectNationCell.h"
#import "ADLGlobalDefine.h"

@interface ADLSelectNationView ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) void (^finish) (NSDictionary *dict);
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *nationArr;
@property (nonatomic, strong) NSString *key;
@end

@implementation ADLSelectNationView

+ (instancetype)showWithFinish:(void (^)(NSDictionary *))finish {
    return [[self alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT) finish:finish];
}

- (instancetype)initWithFrame:(CGRect)frame finish:(void (^)(NSDictionary *))finish {
    if (self = [super initWithFrame:frame]) {
        self.finish = finish;
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat btnW = 55;
        if ([[ADLLocalizedHelper helper].currentLanguage isEqualToString:@"en"]) btnW = 73;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(12, STATUS_HEIGHT+7, SCREEN_WIDTH-btnW-12, NAVIGATION_H-STATUS_HEIGHT-14)];
        bgView.backgroundColor = COLOR_F2F2F2;
        bgView.layer.cornerRadius = 5;
        [self addSubview:bgView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(22, (NAVIGATION_H+STATUS_HEIGHT-16)/2, 16, 16)];
        imgView.image = [UIImage imageNamed:@"icon_search"];
        [self addSubview:imgView];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(50, STATUS_HEIGHT+10, SCREEN_WIDTH-btnW-53, NAVIGATION_H-STATUS_HEIGHT-20)];
        [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.font = [UIFont systemFontOfSize:FONT_SIZE];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = ADLString(@"search");
        textField.returnKeyType = UIReturnKeyDone;
        textField.textColor = COLOR_333333;
        textField.delegate = self;
        [self addSubview:textField];
        
        UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-btnW, STATUS_HEIGHT, btnW, NAVIGATION_H-STATUS_HEIGHT)];
        [cancleBtn addTarget:self action:@selector(clickCancleButton) forControlEvents:UIControlEventTouchUpInside];
        [cancleBtn setTitle:ADLString(@"cancle") forState:UIControlStateNormal];
        [cancleBtn setTitleColor:COLOR_666666 forState:UIControlStateNormal];
        cancleBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        [self addSubview:cancleBtn];
        
        UIView *spView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H-0.5, SCREEN_WIDTH, 0.5)];
        spView.backgroundColor = COLOR_EEEEEE;
        [self addSubview:spView];
        
        self.dataArr = [[NSMutableArray alloc] init];
        self.key = [ADLLocalizedHelper helper].currentLanguage;
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"phone" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        self.nationArr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        [self.dataArr addObjectsFromArray:self.nationArr];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_H, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_H)];
        tableView.contentInset = UIEdgeInsetsMake(0, 0, BOTTOM_H, 0);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = 36;
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
        self.tableView = tableView;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = [UIScreen mainScreen].bounds;
        }];
    }
    return self;
}

#pragma mark ------ UITextFieldDelegate ------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark ------ UITableView Delegate && DataSource ------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADLSelectNationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nation"];
    if (cell == nil) {
        cell = [[ADLSelectNationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nation"];
    }
    NSDictionary *dict = self.dataArr[indexPath.row];
    cell.titLab.text = dict[self.key];
    cell.localeLab.text = dict[@"locale"];
    cell.codeLab.text = dict[@"code"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.finish) self.finish(self.dataArr[indexPath.row]);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self clickCancleButton];
}

#pragma mark ------ 文字改变 ------
- (void)textChanged:(UITextField *)textField {
    [self.dataArr removeAllObjects];
    if (textField.text.length == 0) {
        [self.dataArr addObjectsFromArray:self.nationArr];
    } else {
        for (NSDictionary *dict in self.nationArr) {
            if ([[[dict[self.key] stringValue] lowercaseString] containsString:[textField.text lowercaseString]] || [dict[@"code"] containsString:textField.text]) {
                [self.dataArr addObject:dict];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark ------ 点击取消按钮 ------
- (void)clickCancleButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
