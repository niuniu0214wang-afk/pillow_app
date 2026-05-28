//
//  SleepScoreProgressView.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SleepScoreProgressView : UIView
@property (nonatomic, assign) CGFloat progress; // 0~100
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *progressColor;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
