//
//  QuickTools.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/23.
//

#import "QuickTools.h"

@implementation QuickTools

+ (UIWindow *)mainWindow {
    // 遍历所有已连接场景，取前台活跃的窗口场景
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]] &&
            scene.activationState == UISceneActivationStateForegroundActive) {
            
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            id delegate = windowScene.delegate;
            
            // 拿到 SceneDelegate 里的 window
            if ([delegate respondsToSelector:@selector(window)]) {
                return [delegate window];
            }
        }
    }
    return nil;
}

+ (id)currentSceneDelegate {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] &&
                scene.activationState == UISceneActivationStateForegroundActive) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                return windowScene.delegate;
            }
        }
    }
    return [UIApplication sharedApplication].delegate;
}


@end
