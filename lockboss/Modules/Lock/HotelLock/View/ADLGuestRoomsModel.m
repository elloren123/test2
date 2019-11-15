//
//  ADLGuestRoomsModel.m
//  ADEL-APP
//
//  Created by bailun91 on 2018/6/15.
//

#import "ADLGuestRoomsModel.h"
#import <objc/runtime.h>


@implementation ADLGuestRoomsModel

#pragma mark ------ 遵守NSCoding协议,实现userdefalut存储model ------
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned  int count = 0;
    Ivar *ivars = class_copyIvarList(self.class, &count);
    for (int i = 0; i < count; i++) {
        const char *cname = ivar_getName(ivars[i]);
        NSString *name = [NSString stringWithUTF8String:cname];
        NSString *key = [name substringFromIndex:1];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        unsigned  int count = 0;
        Ivar *ivars = class_copyIvarList(self.class, &count);
        for (int i = 0; i < count; i++) {
            const char *cname = ivar_getName(ivars[i]);
            NSString *name = [NSString stringWithUTF8String:cname];
            NSString *key = [name substringFromIndex:1];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}


@end
