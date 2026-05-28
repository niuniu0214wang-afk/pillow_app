//
//  QuickTools.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuickTools : NSObject

/// 获取当前 App 主窗口（兼容 iOS12 及以下 / iOS13+ SceneDelegate）
+ (UIWindow *)mainWindow;

/// 获取当前活跃的 SceneDelegate
+ (id)currentSceneDelegate;

@end

NS_ASSUME_NONNULL_END
