//
//  FamilyCell.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FamilyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

NS_ASSUME_NONNULL_END
