//
//  DeviceManager.h
//  EonHome
//
//  Created by 刘飞 on 2026/1/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManager : NSObject

+ (instancetype)sharedManager;

// 获取设备唯一标识符
- (NSString *)getDeviceID;

// 删除保存的标识符（用于测试）
- (void)resetDeviceID;

@end

NS_ASSUME_NONNULL_END
