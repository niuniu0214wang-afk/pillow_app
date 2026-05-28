//
//  RegulateSlider.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RegulateSlider;
@protocol controlSliderDelegate <NSObject>
@optional
- (void)controlsliderValue:(RegulateSlider *)slider controlEndValue:(int)value valueIsUp:(BOOL)isUp;
@end


@interface RegulateSlider : UIView

@property (assign, nonatomic) int value;
@property (strong, nonatomic) NSString *title;
@property (weak, nonatomic) id<controlSliderDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
