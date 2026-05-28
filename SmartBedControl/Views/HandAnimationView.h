//
//  HandAnimationView.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HandAnimationView : UIView

- (instancetype)initWithFrame:(CGRect)frame withBedMode:(BedMode)mode;


- (void)didAnimationUp:(BOOL)isUp bodyPart:(int)part;


- (void)stopAniMation;

@end

NS_ASSUME_NONNULL_END
