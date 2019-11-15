//
//  ADLFamilyOpenLockCell.h
//  lockboss
//
//  Created by adel on 2019/10/10.
//  Copyright © 2019 adel. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ADLLockRecordModel.h"

NS_ASSUME_NONNULL_BEGIN
//@class ADLLockModel,ADLDeviceModel;

@interface ADLFamilyOpenLockCell : UITableViewCell

@property (nonatomic, strong) UIView *subView;
@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *lockLabel;
@property (nonatomic, strong) UILabel *openWaylab;
@property (nonatomic, strong) UILabel *lockTyp;
@property (nonatomic, strong) UIView *lienView;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *icon1;
@property (nonatomic, strong) UIImageView *icon2;
@property (nonatomic, strong) UIImageView *icon3;
@property (nonatomic, strong) UIImageView *icon4;
@property (nonatomic, strong) UIImageView *icon5;

//@property (nonatomic, strong) ADLLockRecordModel *model;

@end

NS_ASSUME_NONNULL_END
