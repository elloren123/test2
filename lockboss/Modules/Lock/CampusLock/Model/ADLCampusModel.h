//
//  ADLCampusModel.h
//  lockboss
//
//  Created by bailun91 on 2019/11/13.
//  Copyright © 2019年 adel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADLCampusModel : NSObject

@property (nonatomic, copy) NSString * studentId;//学生id
@property (nonatomic, copy) NSString * status;//int 状态 1：入住，2：外宿 ",
@property (nonatomic, copy) NSString * buildId;//string 楼栋id",
@property (nonatomic, copy) NSString * adminName;//管理员姓名
@property (nonatomic, copy) NSString * adminPhone;//管理手机
@property (nonatomic, copy) NSString * buildName;//楼栋名称
@property (nonatomic, copy) NSString * floorId;//楼层名称"
@property (nonatomic, copy) NSString * dormId;//楼层ID
@property (nonatomic, copy) NSString * dormName;//楼层名称
@property (nonatomic, copy) NSString * bedSum;//床位
@property (nonatomic, copy) NSString * inSum;//入住人数
@property (nonatomic, copy) NSString * deviceId;//设备id
@property (nonatomic, copy) NSString * deviceCode;//壁虎网关/序列号/设备
@property (nonatomic, copy) NSString * deviceName;//"壁虎名称/设备
@property (nonatomic, copy) NSString * deviceFirmwareVersion;//硬件版本号
@property (nonatomic, assign) NSInteger  battery;//电量 int 低于4500就告警 ",
@property (nonatomic, copy) NSString * gatewayId;//壁虎网关ID",
@property (nonatomic, copy) NSString * gatewayCode;//壁虎网关",
@property (nonatomic, copy) NSString * gatewayName;//壁虎名称  ",
@property (nonatomic, copy) NSString * gatewayFirmwareVersion;//固件版本号 ",
@property (nonatomic, copy) NSString * gatewayHardwareVersion;//硬件版本号",
@property (nonatomic, copy) NSString * deviceType;//型号",
@property (nonatomic, assign) NSInteger  deviceStatus;//设备状态 ,//1在线 0离线
@property (nonatomic, copy) NSString * buildingName;//楼栋名称",
@property (nonatomic, copy) NSString * buildingId;//楼栋id
@property (nonatomic, copy) NSString * floorName;//楼层名称
@property (nonatomic, copy) NSString *schoolName;//学校名称

@end

NS_ASSUME_NONNULL_END
