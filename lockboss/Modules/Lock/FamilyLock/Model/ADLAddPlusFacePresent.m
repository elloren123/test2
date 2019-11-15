//
//  ADLAddPlusFacePresent.m
//  lockboss
//
//  Created by adel on 2019/11/12.
//  Copyright © 2019 adel. All rights reserved.
//

#import "ADLAddPlusFacePresent.h"
#import "ADLNetWorkManager.h"
#import "ADELUrlpath.h"

@implementation ADLAddPlusFacePresent{
    NSDictionary *_params;
}

- (instancetype)initWith:(NSDictionary *)params
{
    self = [super init];
    if (self) {
        _params = params;
    }
    return self;
}

-(void)sendAddFaceAFWithSuccess:(Success)success Fial:(Fail)fail{
    
    ADLLog(@"添加人脸时的参数 === %@\n",_params);
    
    [ADLNetWorkManager postWithPath:ADEL_family_addSecretFace parameters:_params autoToast:YES success:^(NSDictionary *responseDict) {
        ADLLog(@"添加人脸请求返回=== %@ \n",responseDict);
        if ([responseDict[@"code"] integerValue] == 10000) {
            success(responseDict);
        } else {
            fail();
        }
    } failure:^(NSError *error) {
        fail();
    }];
    
    
    
    
}

@end
