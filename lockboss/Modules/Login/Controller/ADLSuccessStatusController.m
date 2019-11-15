//
//  ADLSuccessStatusController.m
//  lockboss
//
//  Created by Adel on 2019/11/14.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLSuccessStatusController.h"

@interface ADLSuccessStatusController ()

@end

@implementation ADLSuccessStatusController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2, NAVIGATION_H+75, 80, 80)];
    imgView.image = [UIImage imageNamed:@"login_success"];
    [self.view addSubview:imgView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(50, NAVIGATION_H+160, SCREEN_WIDTH-100, 50)];
    lab.font = [UIFont boldSystemFontOfSize:18];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = COLOR_333333;
    lab.numberOfLines = 0;
    [self.view addSubview:lab];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(30, NAVIGATION_H+250, SCREEN_WIDTH-60, 44);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    btn.backgroundColor = APP_COLOR;
    btn.layer.cornerRadius = 22;
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    if (self.type == ADLSuccessTypeRegisterPhone) {
        lab.text = ADLString(@"register_sus");
        [self addNavigationView:ADLString(@"register")];
        [btn setTitle:ADLString(@"login_go") forState:UIControlStateNormal];
    } else if (self.type == ADLSuccessTypeRegisterEmail) {
        lab.text = ADLString(@"register_email");
        [self addNavigationView:ADLString(@"register")];
        [btn setTitle:ADLString(@"confirm") forState:UIControlStateNormal];
    } else if (self.type == ADLSuccessTypeForgetPassword) {
        lab.text = ADLString(@"modify_sus");
        [self addNavigationView:ADLString(@"pwd_retrieve")];
        [btn setTitle:ADLString(@"login_go") forState:UIControlStateNormal];
    } else if (self.type == ADLSuccessTypeModifyPassword) {
        lab.text = ADLString(@"modify_sus");
        [self addNavigationView:ADLString(@"pwd_modify")];
        [btn setTitle:ADLString(@"confirm") forState:UIControlStateNormal];
    } else {
        lab.text = ADLString(@"modify_sus");
        [self addNavigationView:ADLString(@"modify_phone")];
        [btn setTitle:ADLString(@"confirm") forState:UIControlStateNormal];
    }
}

- (void)clickBtn {
    if (self.type == ADLSuccessTypeModifyPassword || self.type == ADLSuccessTypeModifyPhone) {
        if (self.navigationController.viewControllers.count > 2) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
