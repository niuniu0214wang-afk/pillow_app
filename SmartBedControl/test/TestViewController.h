//
//  TestViewController.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestViewController : UIViewController
@property (nonatomic, strong) UISegmentedControl *sideSegment;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *mattressVisualView;
@property (nonatomic, strong) NSArray<UISlider *> *adjustmentSliders;
@end

NS_ASSUME_NONNULL_END
