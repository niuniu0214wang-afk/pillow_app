//
//  RegulateProgress.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegulateProgress : UIView

@property (strong, nonatomic) NSString *title;

- (void)start;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
