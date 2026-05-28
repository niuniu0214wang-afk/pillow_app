//
//  EonDefine.h
//  EonHome
//
//  Created by 刘飞 on 2025/12/23.
//

#ifndef EonDefine_h
#define EonDefine_h

//-------------------获取设备大小-------------------------
//获取屏幕 宽度、高度
#define iPhoneScreen ([UIScreen mainScreen].bounds)
#define iPhoneWidth  [ScreenUtils shared].screenWidth
#define iPhoneHeight ([UIScreen mainScreen].bounds.size.height)
#define Screen_Scale  ([UIScreen mainScreen].bounds.size.width/320.0)
#define safeBottom [ScreenUtils shared].safeAreaBottom
#define STATUS_BAR_HEIGHT [ScreenUtils shared].statusBarHeight

// 简单宏定义 - 直接返回状态栏高度
//#define STATUS_BAR_HEIGHT ({\
//    CGFloat height = 0;\
//    if (@available(iOS 13.0, *)) {\
//        UIWindow *keyWindow = nil;\
//        for (UIWindow *window in UIApplication.sharedApplication.windows) {\
//            if (window.isKeyWindow) {\
//                keyWindow = window;\
//                break;\
//            }\
//        }\
//        height = keyWindow.windowScene.statusBarManager.statusBarFrame.size.height;\
//    } else {\
//        height = UIApplication.sharedApplication.statusBarFrame.size.height;\
//    }\
//    height;\
//})


// 导航栏高度
#define NAVIGATION_BAR_HEIGHT 44.0f

// 状态栏+导航栏总高度
#define NAVIGATION_HEIGHT (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)

// 标签栏高度（含安全区域）
#define TAB_BAR_HEIGHT (49.0f + safeBottom)

// 安全区域边距
#define SAFE_AREA_INSETS [UIApplication sharedApplication].keyWindow.safeAreaInsets

// 判断设备类型
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// 判断刘海屏
#define IS_IPHONE_X (iPhoneHeight >= 812.0f && IS_IPHONE)

// 比例适配（基于 375pt 设计稿）
#define SCALE(value) ((value) * iPhoneWidth / 375.0f)

// 常用尺寸
#define SCREEN_MAX_LENGTH MAX(iPhoneWidth, iPhoneHeight)
#define SCREEN_MIN_LENGTH MIN(iPhoneWidth, iPhoneHeight)

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)


#define mainColor [UIColor colorWithValue:@"#0d0d0d"]
#define highBlue [UIColor colorWithValue:@"#00d4ff"]
#define purpleColor [UIColor colorWithValue:@"#8b5cf6"]


#endif /* EonDefine_h */
