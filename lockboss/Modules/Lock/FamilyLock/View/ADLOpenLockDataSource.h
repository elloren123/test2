//
//  ADLOpenLockDataSource.h
//  lockboss
//
//  Created by adel on 2019/11/15.
//  Copyright © 2019 adel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CellConfigureBefore)(id cell,id model,NSIndexPath * indexPath);

@interface ADLOpenLockDataSource : NSObject<UITableViewDataSource,UICollectionViewDataSource>

@property (nonatomic, strong)  NSMutableArray *dataArray;

//自定义
- (id)initWithIdentifier:(NSString *)identifier configureBlock:(CellConfigureBefore)before;

@property (nonatomic, strong) IBInspectable NSString *cellIdentifier;

@property (nonatomic, copy) CellConfigureBefore cellConfigureBefore;

- (void)addDataArray:(NSArray *)datas;

- (id)modelsAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
