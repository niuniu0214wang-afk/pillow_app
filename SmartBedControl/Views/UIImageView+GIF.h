//
//  UIImageView+GIF.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (GIF)
- (void)playGifWithName:(NSString *)gifName;
- (void)playGifWithData:(NSData *)gifData;
@end

NS_ASSUME_NONNULL_END
