//
//  SleepChartView.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SleepChartView : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSArray *dataSource;

@end

NS_ASSUME_NONNULL_END
