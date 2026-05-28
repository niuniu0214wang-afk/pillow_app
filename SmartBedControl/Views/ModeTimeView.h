//
//  ModeTimeView.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ModeTimeView;
@protocol modeTimeDelegate <NSObject>

- (void)modeTimeView:(ModeTimeView *)view doTimeLevel:(int)level;

@end

@interface ModeTimeView : UIView

@property (weak, nonatomic) id<modeTimeDelegate> delegate;

- (void)show:(NSInteger)tag;

- (void)dismiss;


@end

NS_ASSUME_NONNULL_END
