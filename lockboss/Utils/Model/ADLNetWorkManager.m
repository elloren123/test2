//
//  ADLNetWorkManager.m
//  lockboss
//
//  Created by adel on 2019/3/26.
//  Copyright © 2019年 adel. All rights reserved.
//

#import "ADLNetWorkManager.h"
#import "ADLLocalizedHelper.h"
#import "ADLRMQConnection.h"
#import "ADLGlobalDefine.h"
#import "ADLUserModel.h"
#import "ADLToast.h"
#import "ADLUtils.h"

#import <AFNetworking.h>
#import <JMessage/JMSGUser.h>

typedef NS_ENUM(NSInteger, ADLUrlType) {
    ADLUrlTypeTest,//测试
    ADLUrlTypeFormal,//正式
    ADLUrlTypeMaLuYao,//马路遥
    ADLUrlTypeZhouWei,//周伟
    ADLUrlTypeLiGui,//李桂
    ADLUrlTypeLiJi,//李冀
};

@interface ADLNetWorkManager ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, assign) ADLUrlType type;
@end

@implementation ADLNetWorkManager

+ (instancetype)sharedManager {
    static ADLNetWorkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ADLNetWorkManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.type = ADLUrlTypeTest;//测试
        //self.type = ADLUrlTypeFormal;//正式
        //self.type = ADLUrlTypeMaLuYao;//马路遥
        //self.type = ADLUrlTypeZhouWei;//周伟
        //self.type = ADLUrlTypeLiGui;//李桂
        //self.type = ADLUrlTypeLiJi;//李冀
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://"]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",@"text/json",@"application/json",@"text/javascript", nil];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:@"ios_0" forHTTPHeaderField:@"login-client-type"];
        [manager.requestSerializer setValue:@"8d0d1589270ea90732972a641a3ab2275fe413a0" forHTTPHeaderField:@"appid"];
        [manager setSecurityPolicy:[self httpsCertificate]];
        self.manager = manager;
    }
    return self;
}

#pragma mark ------ Https 证书 ------
- (AFSecurityPolicy *)httpsCertificate {
    NSString *testPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"cer"];
    NSData *testData = [NSData dataWithContentsOfFile:testPath];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"shop" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData,testData, nil];
    securityPolicy.allowInvalidCertificates = YES;
    return securityPolicy;
}

#pragma mark ------ 设置Token ------
- (void)setToken:(NSString *)token {
    _token = token;
    [self.manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
}

#pragma mark ------ post请求 ------
+ (void)postWithPath:(NSString *)path
          parameters:(NSDictionary *)parameters
           autoToast:(BOOL)autoToast
             success:(void (^)(NSDictionary *responseDict))success
             failure:(void (^)(NSError *error))failure {
    [[self sharedManager] postWithPath:path parameters:parameters autoToast:autoToast success:success failure:failure];
}

- (void)postWithPath:(NSString *)path
          parameters:(NSDictionary *)parameters
           autoToast:(BOOL)autoToast
             success:(void (^)(NSDictionary *responseDict))success
             failure:(void (^)(NSError *error))failure {
    [self.manager POST:[self splicingPath:path] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealwithResponseObject:responseObject autoToast:autoToast success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loc = %@ - %d, path = %@",self.class,__LINE__,task.currentRequest.URL);
        [self dealwithError:error autoToast:autoToast failure:failure];
    }];
}

#pragma mark ------ get请求 ------
+ (void)getWithPath:(NSString *)path
         parameters:(NSDictionary *)parameters
          autoToast:(BOOL)autoToast
            success:(void (^)(NSDictionary *responseDict))success
            failure:(void (^)(NSError *error))failure {
    [[self sharedManager] getWithPath:path parameters:parameters autoToast:autoToast success:success failure:failure];
}

- (void)getWithPath:(NSString *)path
         parameters:(NSDictionary *)parameters
          autoToast:(BOOL)autoToast
            success:(void (^)(NSDictionary *responseDict))success
            failure:(void (^)(NSError *error))failure {
    [self.manager GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealwithResponseObject:responseObject autoToast:autoToast success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self dealwithError:error autoToast:autoToast failure:failure];
    }];
}

#pragma mark ------ Post 字符串数据 ------
+ (void)postStringPath:(NSString *)path
            stringData:(NSData *)stringData
             autoToast:(BOOL)autoToast
               success:(void (^)(NSDictionary *responseDict))success
               failure:(void (^)(NSError *error))failure {
    [[self sharedManager] postStringPath:path stringData:stringData autoToast:autoToast success:success failure:failure];
}

- (void)postStringPath:(NSString *)path
            stringData:(NSData *)stringData
             autoToast:(BOOL)autoToast
               success:(void (^)(NSDictionary *responseDict))success
               failure:(void (^)(NSError *error))failure {
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[self splicingPath:path] parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ios_0" forHTTPHeaderField:@"login-client-type"];
    [request setValue:self.token forHTTPHeaderField:@"token"];
    [request setHTTPBody:stringData];
    [[self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [self dealwithError:error autoToast:autoToast failure:failure];
        } else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSInteger responseCode = [responseObject[@"code"] integerValue];
                if (responseCode == 10000) {
                    if (success) success(responseObject);
                } else if (responseCode == 30003 || responseCode == 30002) {
                    [self loginExpired];
                } else {
                    if (autoToast) [ADLToast showMessage:responseObject[@"msg"]];
                    if (success) success(responseObject);
                }
            } else {
                [self dealwithResponseObject:responseObject autoToast:autoToast success:success];
            }
        }
    }] resume];
}

#pragma mark ------ post 上传图片 ------
+ (void)postImagePath:(NSString *)path
           parameters:(NSDictionary *)parameters
         imageDataArr:(NSArray<NSData *> *)imageDataArr
            imageName:(NSString *)imageName
            autoToast:(BOOL)autoToast
             progress:(void (^)(NSProgress *))progress
              success:(void (^)(NSDictionary *))success
              failure:(void (^)(NSError *))failure {
    [[self sharedManager] postImagePath:path parameters:parameters imageDataArr:imageDataArr imageName:imageName autoToast:autoToast progress:progress success:success failure:failure];
}

- (void)postImagePath:(NSString *)path
           parameters:(NSDictionary *)parameters
         imageDataArr:(NSArray<NSData *> *)imageDataArr
            imageName:(NSString *)imageName
            autoToast:(BOOL)autoToast
             progress:(void (^)(NSProgress *))progress
              success:(void (^)(NSDictionary *))success
              failure:(void (^)(NSError *))failure {
    [self.manager POST:[self splicingPath:path] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmssSSS";
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        
        if (imageDataArr.count == 1) {
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",dateStr];
            [formData appendPartWithFileData:imageDataArr.firstObject name:imageName fileName:fileName mimeType:@"image/jpg"];
            
        } else {
            for (int i = 0; i < imageDataArr.count; i++) {
                NSData *imageData = imageDataArr[i];
                NSString *fileName = [NSString stringWithFormat:@"%@-%02d.jpg",dateStr,i+1];
                [formData appendPartWithFileData:imageData name:imageName fileName:fileName mimeType:@"image/jpg"];
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealwithResponseObject:responseObject autoToast:autoToast success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self dealwithError:error autoToast:autoToast failure:failure];
    }];
}

#pragma mark ------ 下载文件 ------
+ (NSURLSessionDownloadTask *)downloadFilePath:(NSString *)path
                                      progress:(void (^)(NSProgress *progress))progress
                                       success:(void (^)(NSString *filePath))success
                                       failure:(void (^)(NSError *error))failure {
    return [[self sharedManager] downloadFilePath:path progress:progress success:success failure:failure];
}

- (NSURLSessionDownloadTask *)downloadFilePath:(NSString *)path
                                      progress:(void (^)(NSProgress *progress))progress
                                       success:(void (^)(NSString *filePath))success
                                       failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *cachePath = [docPath stringByAppendingPathComponent:@"myCache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filename = [NSString stringWithFormat:@"%@.%@",[ADLUtils md5Encrypt:path lower:YES],[path componentsSeparatedByString:@"."].lastObject];
        NSString *filePath = [cachePath stringByAppendingPathComponent:filename];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success(filePath.path);
            }
        }
    }];
    [task resume];
    return task;
}

#pragma mark ------ 拼接请求地址 ------
- (NSString *)splicingPath:(NSString *)suffix {
    if ([suffix hasPrefix:@"shop"]) {
        if (self.type == ADLUrlTypeFormal) {
            return [NSString stringWithFormat:@"https://shop.adellock.com/%@",suffix];
        } else {
            return [NSString stringWithFormat:@"https://testshop.adellock.com/%@",suffix];
        }
    } else if ([suffix hasPrefix:@"hotel-around"]) {
        if (self.type == ADLUrlTypeFormal) {
            return [NSString stringWithFormat:@"http://shop.adellock.com:8080/%@",suffix];
        } else {
            return [NSString stringWithFormat:@"http://testshop.adellock.com:8080/%@",suffix];
        }
    } else if ([suffix hasPrefix:@"lockboss-api"]) {
        return [NSString stringWithFormat:@"%@%@",[self getMainPrefix],suffix];
        
    } else if ([suffix hasPrefix:@"lockboss-family"]) {
        return [NSString stringWithFormat:@"%@%@",[self getFamilyPrefix],suffix];
        
    } else if ([suffix hasPrefix:@"lockboss-dev"]) {
        return [NSString stringWithFormat:@"%@%@",[self getDevicePrefix],suffix];
        
    } else if ([suffix hasPrefix:@"lockboss-school"]) {
        return [NSString stringWithFormat:@"%@%@",[self getCampusPrefix],suffix];
        
    } else if ([suffix hasPrefix:@"lockboss-mqtt"]) {
        return [NSString stringWithFormat:@"%@%@",[self getMqttPrefix],suffix];
        
    } else {
        return suffix;
    }
}

#pragma mark ------ 开锁主Url ------
- (NSString *)getMainPrefix {
    if (self.type == ADLUrlTypeTest) {//测试
        return @"http://test.isod-ai.com:8087/";
    } else if (self.type == ADLUrlTypeFormal) {//正式
        return @"http://www.isod-ai.com:8087/";
    } else if (self.type == ADLUrlTypeMaLuYao) {//马路遥
        return @"http://192.168.168.49:8080/";
    } else if (self.type == ADLUrlTypeZhouWei) {//周伟
        return @"http://192.168.168.45:8080/";
    } else if (self.type == ADLUrlTypeLiGui) {//李桂
        return @"http://192.168.168.65:8080/";
    } else {//李冀
        return @"http://192.168.168.43:8080/";
    }
}

#pragma mark ------ 家庭Url ------
- (NSString *)getFamilyPrefix {
    if (self.type == ADLUrlTypeTest) {//测试
        return @"http://test.isod-ai.com:8088/";
    } else if (self.type == ADLUrlTypeFormal) {//正式
        return @"http://www.isod-ai.com:8088/";
    } else if (self.type == ADLUrlTypeMaLuYao) {//马路遥
        return @"http://192.168.168.49:8088/";
    } else if (self.type == ADLUrlTypeZhouWei) {//周伟
        return @"http://192.168.168.45:8088/";
    } else if (self.type == ADLUrlTypeLiGui) {//李桂
        return @"http://192.168.168.65:8088/";
    } else {//李冀
        return @"http://192.168.168.43:8088/";
    }
}

#pragma mark ------ 设备Url ------
- (NSString *)getDevicePrefix {
    if (self.type == ADLUrlTypeTest) {//测试
        return @"http://test.isod-ai.com:8086/";
    } else if (self.type == ADLUrlTypeFormal) {//正式
        return @"http://www.isod-ai.com:8086/";
    } else if (self.type == ADLUrlTypeMaLuYao) {//马路遥
        return @"http://192.168.168.49:8081/";
    } else if (self.type == ADLUrlTypeZhouWei) {//周伟
        return @"http://192.168.168.45:8081/";
    } else if (self.type == ADLUrlTypeLiGui) {//李桂
        return @"http://192.168.168.65:8081/";
    } else {//李冀
        return @"http://192.168.168.43:8081/";
    }
}

#pragma mark ------ 校园Url ------
- (NSString *)getCampusPrefix {
    if (self.type == ADLUrlTypeTest) {//测试
        return @"http://test.isod-ai.com:9001/";
    } else if (self.type == ADLUrlTypeFormal) {//正式
        return @"http://www.isod-ai.com:9001/";
    } else if (self.type == ADLUrlTypeMaLuYao) {//马路遥
        return @"http://192.168.168.49:9001/";
    } else if (self.type == ADLUrlTypeZhouWei) {//周伟
        return @"http://192.168.168.45:9001/";
    } else if (self.type == ADLUrlTypeLiGui) {//李桂
        return @"http://192.168.168.65:9001/";
    } else {//李冀
        return @"http://192.168.168.43:9001/";
    }
}

#pragma mark ------ MQTT Url ------
- (NSString *)getMqttPrefix {
    if (self.type == ADLUrlTypeTest) {//测试
        return @"http://test.isod-ai.com:8183/";
    } else if (self.type == ADLUrlTypeFormal) {//正式
        return @"http://www.isod-ai.com:8183/";
    } else if (self.type == ADLUrlTypeMaLuYao) {//马路遥
        return @"http://192.168.168.49:8183/";
    } else if (self.type == ADLUrlTypeZhouWei) {//周伟
        return @"http://192.168.168.45:8183/";
    } else if (self.type == ADLUrlTypeLiGui) {//李桂
        return @"http://192.168.168.65:8183/";
    } else {//李冀
        return @"http://192.168.168.43:8183/";
    }
}

#pragma mark ------ MQ服务器地址 ------
- (NSString *)getMqUri {
    if (self.type == ADLUrlTypeFormal) {
        return @"amqp://admin:AI_lockrabbitmqadmin123@isod-ai.com:5672";
    } else {
        return @"amqp://admin:AI_lockrabbitmqadmin123@129.204.67.226:5672";
    }
}

#pragma mark ------ 压缩图片 ------
- (NSData *)compressImage:(UIImage *)image {
    CGFloat compression = 1;
    NSInteger maxLength = 1048576;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max+min)/2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength*0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

#pragma mark ------ 登录超时 ------
- (void)loginExpired {
    [ADLToast showMessage:ADLString(@"login_expired")];
    UIViewController *controller = [ADLUtils getCurrentViewController];
    if (controller.navigationController) {
        [controller.navigationController popToRootViewControllerAnimated:YES];
    }
    [self removeUserInfo];
}

#pragma mark ------ 清空用户信息 ------
- (void)removeUserInfo {
    [_manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    self.token = nil;
    [ADLUserModel removeUserModel];
    [[ADLUserModel sharedModel] resetUserModel];
    [[ADLRMQConnection sharedConnect] closeConnection];
    [JMSGUser logout:^(id resultObject, NSError *error) {
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:nil userInfo:nil];
}

#pragma mark ------ 处理成功请求 ------
- (void)dealwithResponseObject:(id)responseObject autoToast:(BOOL)autoToast success:(void (^)(NSDictionary *responseDict))success {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    NSInteger code = [dict[@"code"] integerValue];
    if (code == 10000) {
        if (success) success(dict);
    } else if (code == 30003 || code == 30002 || code == 10029) {
        [self loginExpired];
    } else {
        if (autoToast) [ADLToast showMessage:dict[@"msg"]];
        if (success) success(dict);
    }
}

#pragma mark ------ 处理失败请求 ------
- (void)dealwithError:(NSError *)error autoToast:(BOOL)autoToast failure:(void (^)(NSError *error))failure {
    NSLog(@"loc = %@ - %d, desc = %@",self.class,__LINE__,error);
    NSInteger code = error.code;
    if (code == -999) {//取消请求
        if ([ADLToast isShowLoading]) [ADLToast hide];
    } else {
        if (autoToast) {
            if (code == -1009) {//网络不可用
                [ADLToast showMessage:ADLString(@"network_unavailable")];
            } else {
                if (code == -1001) {//请求超时
                    if ([ADLToast isShowLoading]) [ADLToast showMessage:ADLString(@"network_slow")];
                } else {
                    [ADLToast showMessage:ADLString(@"network_wrong")];
                }
            }
        }
        if (failure) failure(error);
    }
}

@end
