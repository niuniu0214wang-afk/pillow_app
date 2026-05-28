//
//  ScreenUtils.m
//  EonHome
//
//  Created by 刘飞 on 2025/12/23.
//

#import "ScreenUtils.h"


@implementation ScreenUtils {
    UIWindowScene *_currentWindowScene;
}

+ (instancetype)shared {
    static ScreenUtils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self updateCurrentWindowScene];
        [self setupObservers];
    }
    return self;
}

- (void)updateCurrentWindowScene {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            _currentWindowScene = (UIWindowScene *)scene;
            break;
        }
    }
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sceneDidActivate:)
                                                 name:UISceneDidActivateNotification
                                               object:nil];
}

- (void)sceneDidActivate:(NSNotification *)notification {
    UIScene *scene = notification.object;
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        _currentWindowScene = (UIWindowScene *)scene;
    }
}

#pragma mark - 基本尺寸信息

- (CGSize)screenSize {
    [self updateCurrentWindowScene];
    if (_currentWindowScene) {
        return _currentWindowScene.screen.bounds.size;
    }
    return [UIScreen mainScreen].bounds.size;
}

- (CGSize)screenSizeInPoints {
    CGSize size = [self screenSize];
    CGFloat scale = [self screenScale];
    return CGSizeMake(size.width / scale, size.height / scale);
}

- (CGFloat)screenScale {
    if (_currentWindowScene) {
        return _currentWindowScene.screen.scale;
    }
    return [UIScreen mainScreen].scale;
}

- (CGFloat)screenWidth {
    return [self screenSize].width;
}

- (CGFloat)screenHeight {
    return [self screenSize].height;
}

- (CGFloat)screenDiagonal {
    CGSize size = [self screenSizeInPoints];
    CGFloat widthInches = size.width / 72.0;  // 72 points per inch
    CGFloat heightInches = size.height / 72.0;
    return sqrt(widthInches * widthInches + heightInches * heightInches);
}

#pragma mark - 安全区域

- (UIEdgeInsets)safeAreaInsets {
    [self updateCurrentWindowScene];
    if (_currentWindowScene && _currentWindowScene.windows.count > 0) {
        UIWindow *window = _currentWindowScene.windows.firstObject;
        if (@available(iOS 11.0, *)) {
            return window.safeAreaInsets;
        }
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)safeAreaTop {
    return [self safeAreaInsets].top;
}

- (CGFloat)safeAreaBottom {
    return [self safeAreaInsets].bottom;
}

- (CGFloat)safeAreaHeight {
    UIEdgeInsets insets = [self safeAreaInsets];
    return [self screenHeight] - insets.top - insets.bottom;
}

#pragma mark - 状态栏和导航栏

- (CGFloat)statusBarHeight {
    [self updateCurrentWindowScene];
    if (_currentWindowScene) {
        if (@available(iOS 13.0, *)) {
            return _currentWindowScene.statusBarManager.statusBarFrame.size.height;
        }
    }
    return UIApplication.sharedApplication.statusBarFrame.size.height;
}

- (CGFloat)navigationBarHeight {
    return 44.0 + [self statusBarHeight];  // 44是标准导航栏高度
}

#pragma mark - 设备判断

- (BOOL)isIPhone {
    [self updateCurrentWindowScene];
    if (_currentWindowScene) {
        return _currentWindowScene.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    }
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

- (BOOL)isIPad {
    [self updateCurrentWindowScene];
    if (_currentWindowScene) {
        return _currentWindowScene.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad;
    }
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (BOOL)isLandscape {
    CGSize size = [self screenSize];
    return size.width > size.height;
}

- (ScreenSizeCategory)screenCategory {
    CGFloat screenWidth = [self screenWidth];
    CGFloat screenHeight = [self screenHeight];
    CGFloat shorterSide = MIN(screenWidth, screenHeight);
    
    // 以点（points）为单位判断
    if ([self isIPad]) {
        return ScreenSizeCategoryiPad;
    } else if (shorterSide >= 414) {
        // iPhone Pro Max, Plus 等
        return ScreenSizeCategoryLarge;
    } else if (shorterSide >= 390) {
        // iPhone 12/13/14 标准版，iPhone X/XS/11 Pro
        return ScreenSizeCategoryXSeries;
    } else if (shorterSide >= 375) {
        // iPhone 6/7/8 Plus, iPhone 12/13 mini
        return ScreenSizeCategoryMedium;
    } else {
        // iPhone SE, iPhone 5/5s
        return ScreenSizeCategorySmall;
    }
}

- (BOOL)isIPhoneXSeries {
    return [self safeAreaBottom] > 0;
}

- (BOOL)isIPhoneSE {
    CGSize size = [self screenSizeInPoints];
    return [self isIPhone] && size.width == 320.0 && size.height == 568.0;
}

- (BOOL)isIPhoneProMax {
    CGSize size = [self screenSizeInPoints];
    return [self isIPhone] &&
           (size.width == 428.0 || size.height == 428.0);  // iPhone 14 Pro Max
}

#pragma mark - 屏幕适配

- (CGFloat)adaptiveValueForSmall:(CGFloat)small
                         medium:(CGFloat)medium
                           large:(CGFloat)large {
    ScreenSizeCategory category = [self screenCategory];
    
    switch (category) {
        case ScreenSizeCategorySmall:
            return small;
        case ScreenSizeCategoryMedium:
        case ScreenSizeCategoryXSeries:
            return medium;
        case ScreenSizeCategoryLarge:
        case ScreenSizeCategoryiPad:
            return large;
    }
}

- (CGFloat)adaptiveFontSize:(CGFloat)baseSize {
    ScreenSizeCategory category = [self screenCategory];
    CGFloat multiplier = 1.0;
    
    switch (category) {
        case ScreenSizeCategorySmall:
            multiplier = 0.9;
            break;
        case ScreenSizeCategoryMedium:
            multiplier = 1.0;
            break;
        case ScreenSizeCategoryXSeries:
            multiplier = 1.05;
            break;
        case ScreenSizeCategoryLarge:
            multiplier = 1.1;
            break;
        case ScreenSizeCategoryiPad:
            multiplier = 1.2;
            break;
    }
    
    return baseSize * multiplier;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
