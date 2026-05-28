//
//  DeviceCell.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet UILabel *rssiLabel;
@end

NS_ASSUME_NONNULL_END
