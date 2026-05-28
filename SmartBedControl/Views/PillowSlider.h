//
//  PillowSlider.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PillowSlider;
@protocol PillowSliderDelegate <NSObject>

- (void)pillowSlider:(PillowSlider *)slider pressureValue:(int)value;

@end


@interface PillowSlider : UIView
@property (assign, nonatomic) int value;
@property (strong, nonatomic) NSString *title;
@property (weak, nonatomic) id<PillowSliderDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
