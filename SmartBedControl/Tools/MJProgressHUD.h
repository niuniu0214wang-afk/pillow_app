//
//  MJProgressHUD.h
//  EonHome
//
//  Created by 刘飞 on 2026/1/20.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJProgressHUD : MBProgressHUD


+ (void)onlyShowMessage:(NSString *)message afterDelay:(NSTimeInterval)delay showAddTo:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
