//
//  ADLBindOptionController.h
//  lockboss
//
//  Created by Adel on 2019/11/14.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLBaseViewController.h"

@interface ADLBindOptionController : ADLBaseViewController

///第三方unionId
@property (nonatomic, strong) NSString *unionId;

///1QQ  2微信
@property (nonatomic, assign) NSInteger type;

///绑定成功回调
@property (nonatomic, copy) void (^finishLogin) (void);

@end
