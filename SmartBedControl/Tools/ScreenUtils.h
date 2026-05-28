//
//  ScreenUtils.h
//  EonHome
//
//  Created by 刘飞 on 2025/12/23.
//

#import <Foundation/Foundation.h>

// ScreenUtils.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ScreenSizeCategory) {
    ScreenSizeCategorySmall,      // iPhone SE 等小屏
    ScreenSizeCategoryMedium,     // iPhone 标准尺寸
    ScreenSizeCategoryLarge,      // iPhone Plus/Pro Max
    ScreenSizeCategoryXSeries,    // 刘海屏 iPhone
    ScreenSizeCategoryiPad        // iPad
};


typedef NS_ENUM(NSInteger, BedMode) {
    BedNormal,          //基础款   3气囊   蓝牙名称MJ-10
    BedPro,             //        6气囊   蓝牙名称MJ-11
    BedMax,             //旗舰款   12气囊
    PillowNormal        //枕头基础款     蓝牙名称MJ-20
};

typedef NS_ENUM(NSInteger, bodyType) {
    Head,         //头部
    Body          //全身
};

//typedef NS_ENUM(NSInteger, bodyPose) {
//    SupineLie,          //仰卧
//    SideLie             //全身
//};

@interface ScreenUtils : NSObject

// 单例
+ (instancetype)shared;

// 基本尺寸信息
- (CGSize)screenSize;                     // 物理像素尺寸
- (CGSize)screenSizeInPoints;             // 点尺寸
- (CGFloat)screenScale;                   // 缩放比例
- (CGFloat)screenWidth;                   // 屏幕宽度
- (CGFloat)screenHeight;                  // 屏幕高度
- (CGFloat)screenDiagonal;                // 屏幕对角线长度（英寸）

// 安全区域
- (UIEdgeInsets)safeAreaInsets;
- (CGFloat)safeAreaTop;
- (CGFloat)safeAreaBottom;
- (CGFloat)safeAreaHeight;

// 状态栏和导航栏
- (CGFloat)statusBarHeight;
- (CGFloat)navigationBarHeight;

// 设备判断
- (BOOL)isIPhone;
- (BOOL)isIPad;
- (BOOL)isLandscape;                      // 是否横屏
- (ScreenSizeCategory)screenCategory;     // 屏幕尺寸分类

// 屏幕类型判断
- (BOOL)isIPhoneXSeries;                  // 是否是刘海屏 iPhone
- (BOOL)isIPhoneSE;                       // 是否是 iPhone SE
- (BOOL)isIPhoneProMax;                   // 是否是 iPhone Pro Max

// 屏幕适配
- (CGFloat)adaptiveValueForSmall:(CGFloat)small
                         medium:(CGFloat)medium
                           large:(CGFloat)large;
- (CGFloat)adaptiveFontSize:(CGFloat)baseSize;

@end

NS_ASSUME_NONNULL_END

