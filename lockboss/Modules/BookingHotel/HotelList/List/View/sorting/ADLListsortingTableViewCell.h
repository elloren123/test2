//
//  ADLListsortingTableViewCell.h
//  lockboss
//
//  Created by adel on 2019/9/20.
//  Copyright © 2019 adel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADLListsortingTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic ,strong)UILabel *title;
@end

NS_ASSUME_NONNULL_END
