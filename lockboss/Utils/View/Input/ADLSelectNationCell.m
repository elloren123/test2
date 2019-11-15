//
//  ADLSelectNationCell.m
//  lockboss
//
//  Created by adel on 2019/7/3.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLSelectNationCell.h"

@implementation ADLSelectNationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *titLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-136, 36)];
        titLab.font = [UIFont systemFontOfSize:14];
        titLab.textColor = COLOR_333333;
        [self.contentView addSubview:titLab];
        self.titLab = titLab;
        
        UILabel *localeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-112, 0, 50, 36)];
        localeLab.font = [UIFont systemFontOfSize:14];
        localeLab.textColor = COLOR_999999;
        [self.contentView addSubview:localeLab];
        self.localeLab = localeLab;
        
        UILabel *codeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 0, 50, 36)];
        codeLab.font = [UIFont systemFontOfSize:14];
        codeLab.textColor = COLOR_999999;
        [self.contentView addSubview:codeLab];
        self.codeLab = codeLab;
    }
    return self;
}

@end
