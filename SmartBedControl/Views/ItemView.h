//
//  ItemView.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItemView : UIView

@property (assign, nonatomic) BOOL isSelected;


- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withImageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
