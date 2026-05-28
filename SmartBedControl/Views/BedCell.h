//
//  BedCell.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BedCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *bedName;
@property (strong, nonatomic) IBOutlet UILabel *bedMode;
@property (strong, nonatomic) IBOutlet UIView *boomView;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIImageView *deviceImage;
@end

NS_ASSUME_NONNULL_END
